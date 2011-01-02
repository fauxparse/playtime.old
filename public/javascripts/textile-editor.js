/*

Textile Editor v0.2 (ZIP Version)
created by: dave olsen, wvu web services
updated on: october 1, 2007
created on: march 17, 2007
project page: slateinfo.blogs.wvu.edu

inspired by: 
 - Patrick Woods, http://www.hakjoon.com/code/38/textile-quicktags-redirect & 
 - Alex King, http://alexking.org/projects/js-quicktags

features:
 - supports: IE7, FF2, Safari2
 - ability to use "simple" vs. "extended" editor
 - supports all block elements in textile except footnote
 - supports all block modifier elements in textile
 - supports simple ordered and unordered lists
 - supports most of the phrase modifiers, very easy to add the missing ones
 - supports multiple-paragraph modification
 - can have multiple "editors" on one page, access key use in this environment is flaky
 - access key support
 - select text to add and remove tags, selection stays highlighted
 - seamlessly change between tags and modifiers
 - doesn't need to be in the body onload tag
 - can supply your own, custom IDs for the editor to be drawn around

todo:
 - a clean way of providing image and link inserts
 - get the selection to properly show in IE

more on textile:
 - Textism, http://www.textism.com/tools/textile/index.php
 - Textile Reference, http://hobix.com/textile/

*/

var TEH_PATH = ''; // Path to TEH plugin, include /'s if needed

// Define Button Object
function TextileEditorButton(id, display, tagStart, tagEnd, access, title, sve, open) {
	this.id = id;				// used to name the toolbar button
	this.display = display;		// label on button
	this.tagStart = tagStart; 	// open tag
	this.tagEnd = tagEnd;		// close tag
	this.access = access;		// set to -1 if tag does not need to be closed
	this.title = title;			// sets the title attribute of the button to give 'tool tips'
	this.sve = sve;				// sve = simple vs. extended. add an 's' to make it show up in the simple toolbar
	this.open = open;			// set to -1 if tag does not need to be closed
	this.standard = true;  // this is a standard button
}

function TextileEditorButtonSeparator(sve) {
	this.separator = true;
	this.sve = sve;
}

var TextileEditor = new Class({
  buttons: [
    new TextileEditorButton('ed_strong',			'bold.png',          '*',   '*',  'b', 'Bold','s'),
    new TextileEditorButton('ed_emphasis',		'italic.png',        '_',   '_',  'i', 'Italicize','s'),
    new TextileEditorButton('ed_underline',	'underline.png',     '+',   '+',  'u', 'Underline','s'),
    new TextileEditorButton('ed_ol',					'list_numbers.png',  ' # ', '\n', ',', 'Numbered List'),
    new TextileEditorButton('ed_ul',					'list_bullets.png',  ' * ', '\n', '.', 'Bulleted List'),
    new TextileEditorButton('ed_h3',					'h3.png',            'h3',  '\n', '3', 'Heading'),
    new TextileEditorButton('ed_block',   		'blockquote.png',    'bq',  '\n', 'q', 'Blockquote'),
  ],
  
  // create the toolbar (edToolbar)
	initialize: function(canvas, view) {
		var toolbar = document.createElement("div");
		toolbar.id = "textile-toolbar-" + canvas;
		toolbar.className = 'textile-toolbar';
		this.canvas = document.getElementById(canvas);
		this.canvas.parentNode.insertBefore(toolbar, this.canvas);
    this.openTags = new Array();

		// Create the local Button array by assigning theButtons array to edButtons
		var edButtons = new Array();
		edButtons = this.buttons;
		
		var standardButtons = new Array();
		for(var i = 0; i < edButtons.length; i++) {
			var thisButton = this.prepareButton(edButtons[i]);
			if (view == 's') {
				if (edButtons[i].sve == 's') {
					toolbar.appendChild(thisButton);
					standardButtons.push(thisButton);
				}
			}	else {
				if (typeof thisButton == 'string') {
				  toolbar.innerHTML += thisButton;
				} else {
  				toolbar.appendChild(thisButton);
          standardButtons.push(thisButton);
        }
			}
		} // end for
		
		var te = this;
		$A(toolbar.getElementsByTagName('button')).each(function(button) {
			if (!button.onclick) {
				button.onclick = function() { te.insertTag(button); return false; }
			} // end if
			
			button.tagStart = button.getAttribute('tagStart');
			button.tagEnd = button.getAttribute('tagEnd');
			button.open = button.getAttribute('open');
			button.textile_editor = te;
			button.canvas = te.canvas;
		});
	}, // end initialize
	
	// draw individual buttons (edShowButton)
	prepareButton: function(button) {
		if (button.separator) {
			var theButton = document.createElement('span');
			theButton.className = 'ed_sep';
			return theButton;
		}

		if (button.standard) {
			var theButton = document.createElement("button");
			theButton.id = button.id;
			theButton.setAttribute('class', 'standard');
	    theButton.setAttribute('tagStart', button.tagStart);
   	  theButton.setAttribute('tagEnd', button.tagEnd);
   	  theButton.setAttribute('open', button.open);

		  var img = document.createElement('img');
		  img.src = '/images/textile/' + button.display;
		  theButton.appendChild(img);
	  } else {
	    return button;
		} // end if !custom

		theButton.accessKey = button.access;
		theButton.title = button.title;
		return theButton;	
	}, // end prepareButton
	
	// if clicked, no selected text, tag not open highlight button
	// (edAddTag)
	addTag: function(button) {
		if (button.tagEnd != '') {
			this.openTags[this.openTags.length] = button;
			//var el = document.getElementById(button.id);
			//el.className = 'selected';
			button.className = 'selected';
		}
	}, // end addTag

	// if clicked, no selected text, tag open lowlight button
	// (edRemoveTag)
	removeTag: function(button) {
		for (i = 0; i < this.openTags.length; i++) {
			if (this.openTags[i] == button) {
				this.openTags.splice(button, 1);
				//var el = document.getElementById(button.id);
				//el.className = 'unselected';
				button.className = 'unselected';
			}
		}
	}, // end removeTag

	// see if there are open tags. for the remove tag bit...
	// (edCheckOpenTags)
	checkOpenTags: function(button) {
		var tag = 0;
		for (i = 0; i < this.openTags.length; i++) {
			if (this.openTags[i] == button) {
				tag++;
			}
		}
		if (tag > 0) {
			return true; // tag found
		}
		else {
			return false; // tag not found
		}
	}, // end checkOpenTags

	// insert the tag. this is the bulk of the code.
	// (edInsertTag)
  insertTag: function(button, tagStart, tagEnd) {
	  var myField = button.canvas;
		myField.focus();

    if (tagStart) {
	    button.tagStart = tagStart;
      button.tagEnd = tagEnd ? tagEnd : '\n';
    }

		var textSelected = false;
		var finalText = '';
		var FF = false;

		// grab the text that's going to be manipulated, by browser
		if (document.selection) { // IE support
			sel = document.selection.createRange();

			// set-up the text vars
			var beginningText = '';
			var followupText = '';
			var selectedText = sel.text;

			// check if text has been selected
			if (sel.text.length > 0) {
				textSelected = true;	
			}

			// set-up newline regex's so we can swap tags across multiple paragraphs
			var newlineReplaceRegexClean = /\r\n\s\n/g;
			var newlineReplaceRegexDirty = '\\r\\n\\s\\n';
			var newlineReplaceClean = '\r\n\n';
		}
		else if (myField.selectionStart || myField.selectionStart == '0') { // MOZ/FF/NS/S support

			// figure out cursor and selection positions
			var startPos = myField.selectionStart;
			var endPos = myField.selectionEnd;
			var cursorPos = endPos;
			var scrollTop = myField.scrollTop;
			FF = true; // note that is is a FF/MOZ/NS/S browser

			// set-up the text vars
			var beginningText = myField.value.substring(0, startPos);
			var followupText = myField.value.substring(endPos, myField.value.length);

			// check if text has been selected
			if (startPos != endPos) {
				textSelected = true;
				var selectedText = myField.value.substring(startPos, endPos);	
			}

			// set-up newline regex's so we can swap tags across multiple paragraphs
			var newlineReplaceRegexClean = /\n\n/g;
			var newlineReplaceRegexDirty = '\\n\\n';
			var newlineReplaceClean = '\n\n';
		}


		// if there is text that has been highlighted...
		if (textSelected) {

			// set-up some defaults for how to handle bad new line characters
			var newlineStart = '';
			var newlineStartPos = 0;
			var newlineEnd = '';
			var newlineEndPos = 0;
			var newlineFollowup = '';

			// set-up some defaults for how to handle placing the beginning and end of selection
			var posDiffPos = 0;
			var posDiffNeg = 0;
			var mplier = 1;

			// remove newline from the beginning of the selectedText.
			if (selectedText.match(/^\n/)) {
				selectedText = selectedText.replace(/^\n/,'');
				newlineStart = '\n';
				newlineStartpos = 1;
			}

			// remove newline from the end of the selectedText.
			if (selectedText.match(/\n$/g)) {
				selectedText = selectedText.replace(/\n$/g,'');
				newlineEnd = '\n';
				newlineEndPos = 1;
			}

			// no clue, i'm sure it made sense at the time i wrote it
			if (followupText.match(/^\n/)) {
				newlineFollowup = '';
			}
			else {
				newlineFollowup = '\n\n';
			}

			// first off let's check if the user is trying to mess with lists
			if ((button.tagStart == ' * ') || (button.tagStart == ' # ')) {

				listItems = 0; // sets up a default to be able to properly manipulate final selection

				// set-up all of the regex's
				re_start = new RegExp('^ (\\*|\\#) ','g');
				if (button.tagStart == ' # ') {
					re_tag = new RegExp(' \\# ','g'); // because of JS regex stupidity i need an if/else to properly set it up, could have done it with a regex replace though
				}
				else {
					re_tag = new RegExp(' \\* ','g');
				}
				re_replace = new RegExp(' (\\*|\\#) ','g');

				// try to remove bullets in text copied from ms word **Mac Only!** 
				re_word_bullet_m_s = new RegExp('• ','g'); // mac/safari
				re_word_bullet_m_f = new RegExp('∑ ','g'); // mac/firefox
				selectedText = selectedText.replace(re_word_bullet_m_s,'').replace(re_word_bullet_m_f,'');

				// if the selected text starts with one of the tags we're working with...
				if (selectedText.match(re_start)) {

					// if tag that begins the selection matches the one clicked, remove them all
					if (selectedText.match(re_tag)) {
						finalText = beginningText
									  + newlineStart
									  + selectedText.replace(re_replace,'')
									  + newlineEnd
									  + followupText;
						if (matches = selectedText.match(/ (\*|\#) /g)) {
							listItems = matches.length;
						}
						posDiffNeg = listItems*3; // how many list items were there because that's 3 spaces to remove from final selection
					}

					// else replace the current tag type with the selected tag type
					else {
						finalText = beginningText
									  + newlineStart
									  + selectedText.replace(re_replace,button.tagStart)
									  + newlineEnd
									  + followupText;
					}
				}

				// else try to create the list type
				// NOTE: the items in a list will only be replaced if a newline starts with some character, not a space
				else {
					finalText = beginningText
								  + newlineStart
					              + button.tagStart
								  + selectedText.replace(newlineReplaceRegexClean,newlineReplaceClean + button.tagStart).replace(/\n(\S)/g,'\n' + button.tagStart + '$1')
								  + newlineEnd
								  + followupText;
					if (matches = selectedText.match(/\n(\S)/g)) {
						listItems = matches.length;
					}
					posDiffPos = 3 + listItems*3;
				}	
			}

			// now lets look and see if the user is trying to muck with a block or block modifier
			else if (button.tagStart.match(/^(h1|h2|h3|h4|h5|h6|bq|p|\>|\<\>|\<|\=|\(|\))/g)) {

				var insertTag = '';
				var insertModifier = '';
				var tagPartBlock = '';
				var tagPartModifier = '';
				var tagPartModifierOrig = ''; // ugly hack but it's late
				var drawSwitch = '';
				var captureIndentStart = false;
				var captureListStart = false;
				var periodAddition = '\\. ';
				var periodAdditionClean = '. ';
				var listItemsAddition = 0;

				var re_list_items = new RegExp('(\\*+|\\#+)','g'); // need this regex later on when checking indentation of lists

				var re_block_modifier = new RegExp('^(h1|h2|h3|h4|h5|h6|bq|p| [\\*]{1,} | [\\#]{1,} |)(\\>|\\<\\>|\\<|\\=|[\\(]{1,}|[\\)]{1,6}|)','g');
				if (tagPartMatches = re_block_modifier.exec(selectedText)) {
					tagPartBlock = tagPartMatches[1];
					tagPartModifier = tagPartMatches[2];
					tagPartModifierOrig = tagPartMatches[2];
					tagPartModifierOrig = tagPartModifierOrig.replace(/\(/g,"\\(");
				}

				// if tag already up is the same as the tag provided replace the whole tag
				if (tagPartBlock == button.tagStart) { 
					insertTag  = tagPartBlock + tagPartModifierOrig; // use Orig because it's escaped for regex
					drawSwitch = 0; 
				}
				// else if let's check to add/remove block modifier
				else if ((tagPartModifier == button.tagStart) || (newm = tagPartModifier.match(/[\(]{2,}/g))) {
					if ((button.tagStart == '(') || (button.tagStart == ')')) {
						var indentLength = tagPartModifier.length;
						if (button.tagStart == '(') {
							indentLength = indentLength + 1;
						}
						else {
							indentLength = indentLength - 1;
						}
						for (var i = 0; i < indentLength; i++) {
							insertModifier = insertModifier + '(';
						}
						insertTag = tagPartBlock + insertModifier;
					}
					else {
						if (button.tagStart == tagPartModifier) {
							insertTag =  tagPartBlock;
					    } // going to rely on the default empty insertModifier
						else {

							if (button.tagStart.match(/(\>|\<\>|\<|\=)/g)) {
								insertTag = tagPartBlock + button.tagStart;
							}
							else {
								insertTag = button.tagStart + tagPartModifier;
							}
						}

					}
					drawSwitch = 1;
				}
				// indentation of list items
				else if (listPartMatches = re_list_items.exec(tagPartBlock)) {
						var listTypeMatch = listPartMatches[1];
						var indentLength = tagPartBlock.length - 2;
						var listInsert = '';
						if (button.tagStart == '(') {
							indentLength = indentLength + 1;
						}
						else {
							indentLength = indentLength - 1;
						}
						if (listTypeMatch.match(/[\*]{1,}/g)) {
							var listType = '*';
							var listReplace = '\\*';
						}
						else {
							var listType = '#';
							var listReplace = '\\#';
						}
						for (var i = 0; i < indentLength; i++) {
							listInsert = listInsert + listType;
						}
						if (listInsert != '') {
							insertTag = ' ' + listInsert + ' ';
						}
						else {
							insertTag = '';
						}
						tagPartBlock = tagPartBlock.replace(/(\*|\#)/g,listReplace);
						drawSwitch = 1;
						captureListStart = true;
						periodAddition = '';
						periodAdditionClean = '';
						if (matches = selectedText.match(/\n\s/g)) {
							listItemsAddition = matches.length;
						}
				}
				// must be a block modification e.g. p>. to p<.
				else {

					// if this is a block modification/addition
					if (button.tagStart.match(/(h1|h2|h3|h4|h5|h6|bq|p)/g)) { 
						if (tagPartBlock == '') {
							drawSwitch = 2;
						}
						else {
							drawSwitch = 1;
						}

						insertTag = button.tagStart + tagPartModifier;
					}

					// else this is a modifier modification/addition
					else {
						if ((tagPartModifier == '') && (tagPartBlock != '')) {
							drawSwitch = 1;
						}
						else if (tagPartModifier == '') {
							drawSwitch = 2;
						}
						else {
							drawSwitch = 1;
						}

						// if no tag part block but a modifier we need at least the p tag
						if (tagPartBlock == '') {
							tagPartBlock = 'p';
						}

						//make sure to swap out outdent
						if (button.tagStart == ')') {
							tagPartModifier = '';
						}
						else {
							tagPartModifier = button.tagStart;
							captureIndentStart = true; // ugly hack to fix issue with proper selection handling
						}

						insertTag = tagPartBlock + tagPartModifier;
					}
				}

				mplier = 0;
				if (captureListStart || (tagPartModifier.match(/[\(\)]{1,}/g))) {
					re_start = new RegExp(insertTag.escape + periodAddition,'g'); // for tags that mimic regex properties, parens + list tags
				}
				else {
					re_start = new RegExp(insertTag + periodAddition,'g'); // for tags that don't, why i can't just escape everything i have no clue
				}
				re_old = new RegExp(tagPartBlock + tagPartModifierOrig + periodAddition,'g');
				re_middle = new RegExp(newlineReplaceRegexDirty + insertTag.escape + periodAddition.escape,'g');
				re_tag = new RegExp(insertTag.escape + periodAddition.escape,'g');

				// *************************************************************************************************************************
				// this is where everything gets swapped around or inserted, bullets and single options have their own if/else statements
				// *************************************************************************************************************************
				if ((drawSwitch == 0) || (drawSwitch == 1)) {
					if (drawSwitch == 0) { // completely removing a tag
						finalText = beginningText
									  + newlineStart
									  + selectedText.replace(re_start,'').replace(re_middle,newlineReplaceClean)
									  + newlineEnd
									  + followupText;
						if (matches = selectedText.match(newlineReplaceRegexClean)) {
							mplier = mplier + matches.length;
						}
						posDiffNeg = insertTag.length + 2 + (mplier*4);
					}
					else { // modifying a tag, though we do delete bullets here
						finalText = beginningText
									  + newlineStart
									  + selectedText.replace(re_old,insertTag + periodAdditionClean)
									  + newlineEnd
									  + followupText;

						if (matches = selectedText.match(newlineReplaceRegexClean)) {
							mplier = mplier + matches.length;
						}
						// figure out the length of various elements to modify the selection position
						if (captureIndentStart) { // need to double-check that this wasn't the first indent
							tagPreviousLength = tagPartBlock.length;
							tagCurrentLength = insertTag.length;
						}
						else if (captureListStart) { // if this is a list we're manipulating
							if (button.tagStart == '(') { // if indenting
								tagPreviousLength = listTypeMatch.length + 2;
								tagCurrentLength = insertTag.length + listItemsAddition;
							}
							else if (insertTag.match(/(\*|\#)/g)) { // if removing but still has bullets
								tagPreviousLength = insertTag.length + listItemsAddition;
								tagCurrentLength = listTypeMatch.length;
							}
							else {  // if removing last bullet
								tagPreviousLength = insertTag.length + listItemsAddition;
								tagCurrentLength = listTypeMatch.length - (3*listItemsAddition) - 1;
							}
						}
						else { // everything else
							tagPreviousLength = tagPartBlock.length + tagPartModifier.length;
							tagCurrentLength = insertTag.length;
						}
						if (tagCurrentLength > tagPreviousLength) {
							posDiffPos = (tagCurrentLength - tagPreviousLength) + (mplier*(tagCurrentLength - tagPreviousLength));
						}
						else {
							posDiffNeg = (tagPreviousLength - tagCurrentLength) + (mplier*(tagPreviousLength - tagCurrentLength));
						}
					}
				}
				else { // for adding tags other then bullets (have their own statement)
					finalText = beginningText
								  + newlineStart
					              + insertTag + '. '
								  + selectedText.replace(newlineReplaceRegexClean,button.tagEnd + '\n' + insertTag + '. ')
								  + newlineFollowup
								  + newlineEnd
								  + followupText;
					if (matches = selectedText.match(newlineReplaceRegexClean)) {
						mplier = mplier + matches.length;
					}
					posDiffPos = insertTag.length + 2 + (mplier*4);
				}				
			}

			// swap in and out the simple tags around a selection like bold
			else {

				mplier = 1; // the multiplier for the tag length
				re_start = new RegExp('^\\' + button.tagStart,'g');
				re_end =  new RegExp('\\' + button.tagEnd + '$','g');
				re_middle = new RegExp('\\' + button.tagEnd + newlineReplaceRegexDirty + '\\' + button.tagStart,'g');
				if (selectedText.match(re_start) && selectedText.match(re_end)) {
					finalText = beginningText
								  + newlineStart
								  + selectedText.replace(re_start,'').replace(re_end,'').replace(re_middle,newlineReplaceClean)
								  + newlineEnd
								  + followupText;
					if (matches = selectedText.match(newlineReplaceRegexClean)) {
						mplier = mplier + matches.length;
					}
					posDiffNeg = button.tagStart.length*mplier + button.tagEnd.length*mplier;
				}
				else {
					finalText = beginningText
								  + newlineStart
					              + button.tagStart
								  + selectedText.replace(newlineReplaceRegexClean,button.tagEnd + newlineReplaceClean + button.tagStart)
								  + button.tagEnd
								  + newlineEnd
								  + followupText;
					if (matches = selectedText.match(newlineReplaceRegexClean)) {
						mplier = mplier + matches.length;
					}
					posDiffPos = (button.tagStart.length*mplier) + (button.tagEnd.length*mplier);
				}
			}

			cursorPos += button.tagStart.length + button.tagEnd.length;

		}

		// just swap in and out single values, e.g. someone clicks b they'll get a *
		else {
			var buttonStart = '';
			var buttonEnd = '';
			var re_p = new RegExp('(\\<|\\>|\\=|\\<\\>|\\(|\\))','g');
			var re_h = new RegExp('^(h1|h2|h3|h4|h5|h6|p|bq)','g');
			if (!this.checkOpenTags(button) || button.tagEnd == '') { // opening tag

			 	if (button.tagStart.match(re_h)) {
					buttonStart = button.tagStart + '. ';
				}
				else {
					buttonStart = button.tagStart;
				}
				if (button.tagStart.match(re_p)) { // make sure that invoking block modifiers don't do anything
					finalText = beginningText 
					           + followupText;
					cursorPos = startPos;
				}
				else {
					finalText = beginningText 
					            + buttonStart
					            + followupText;
					this.addTag(button);
					cursorPos = startPos + buttonStart.length;
				}

			}
			else {  // closing tag
				if (button.tagStart.match(re_p)) {
					buttonEnd = '\n\n';
				}
				else if (button.tagStart.match(re_h)) {
					buttonEnd = '\n\n';
				}
				else {
					buttonEnd = button.tagEnd
				}
				finalText = beginningText 
				            + button.tagEnd
				            + followupText;
				this.removeTag(button);
				cursorPos = startPos + button.tagEnd.length;
			}
		}

		// set the appropriate DOM value with the final text
		if (FF == true) {
			myField.value = finalText;
			myField.scrollTop = scrollTop;
		}
		else {
			sel.text = finalText;
		}

		// build up the selection capture, doesn't work in IE
		if (textSelected) {
			myField.selectionStart = startPos + newlineStartPos;
			myField.selectionEnd = endPos + posDiffPos - posDiffNeg - newlineEndPos;
			//alert('s: ' + myField.selectionStart + ' e: ' + myField.selectionEnd + ' sp: ' + startPos + ' ep: ' + endPos + ' pdp: ' + posDiffPos + ' pdn: ' + posDiffNeg)
		}
		else {
			myField.selectionStart = cursorPos;
			myField.selectionEnd = cursorPos;
		}
	} // end insertTag
}); // end class

// add class methods
Object.extend(TextileEditor, TextileEditor.Methods);
var teButtons = TextileEditor.buttons;


/***************************************
*
*	Javascript Textile->HTML conversion
*
*	ben@ben-daglish.net (with thanks to John Hughes for improvements)
*   Issued under the "do what you like with it - I take no respnsibility" licence
****************************************/

var inpr,inbq,inbqq,html;
var aliases = new Array;
var alg={'>':'right','<':'left','=':'center','<>':'justify','~':'bottom','^':'top'};
var ent={"'":"&#8217;"," - ":" &#8211; ","--":"&#8212;"," x ":" &#215; ","\\.\\.\\.":"&#8230;","\\(C\\)":"&#169;","\\(R\\)":"&#174;","\\(TM\\)":"&#8482;"};
var tags={"b":"\\*\\*","i":"__","em":"_","strong":"\\*","cite":"\\?\\?","sup":"\\^","sub":"~","span":"\\%","del":"-","code":"@","ins":"\\+","del":"-"};
var le="\n\n";
var lstlev=0,lst="",elst="",intable=0,mm="";
var para = /^p(\S*)\.\s*(.*)/;
var rfn = /^fn(\d+)\.\s*(.*)/;
var bq = /^bq\.(\.)?\s*/;
var table=/^table\s*{(.*)}\..*/;
var trstyle = /^\{(\S+)\}\.\s*\|/;

function convert(t) {
	var lines = t.split(/\r?\n/);
	html="";
	inpr=inbq=inbqq=0;
	for(var i=0;i<lines.length;i++) {
		if(lines[i].indexOf("[") == 0) {
			var m = lines[i].indexOf("]");
			aliases[lines[i].substring(1,m)]=lines[i].substring(m+1);
		}
	}
	for(i=0;i<lines.length;i++) {
		if (lines[i].indexOf("[") == 0) {continue;}
		if(mm=para.exec(lines[i])){stp(1);inpr=1;html += lines[i].replace(para,"<p"+make_attr(mm[1])+">"+prep(mm[2]));continue;}
		if(mm = /^h(\d)(\S*)\.\s*(.*)/.exec(lines[i])){stp(1);html += tag("h"+mm[1],make_attr(mm[2]),prep(mm[3]))+le;continue;}
		if(mm=rfn.exec(lines[i])){stp(1);inpr=1;html+=lines[i].replace(rfn,'<p id="fn'+mm[1]+'"><sup>'+mm[1]+'<\/sup>'+prep(mm[2]));continue;}
		if (lines[i].indexOf("*") == 0) {lst="<ul>";elst="<\/ul>";}
		else if (lines[i].indexOf("#") == 0) {lst="<\ol>";elst="<\/ol>";}
		else {while (lstlev > 0) {html += elst;if(lstlev > 1){html += "<\/li>";}else{html+="\n";}html+="\n";lstlev--;}lst="";}
		if(lst) {
			stp(1);
			var m = /^([*#]+)\s*(.*)/.exec(lines[i]);
			var lev = m[1].length;
			while(lev < lstlev) {html += elst+"<\/li>\n";lstlev--;}
			while(lstlev < lev) {html=html.replace(/<\/li>\n$/,"\n");html += lst;lstlev++;}
			html += tag("li","",prep(m[2]))+"\n";
			continue;
		}
		if (lines[i].match(table)){stp(1);intable=1;html += lines[i].replace(table,'<table style="$1;">\n');continue;}
		if ((lines[i].indexOf("|") == 0)  || (lines[i].match(trstyle)) ) {
			stp(1);
			if(!intable) {html += "<table>\n";intable=1;}
			var rowst="";var trow="";
			var ts=trstyle.exec(lines[i]);
			if(ts){rowst=qat('style',ts[1]);lines[i]=lines[i].replace(trstyle,"\|");}
			var cells = lines[i].split("|");
			for(j=1;j<cells.length-1;j++) {
				var ttag="td";
				if(cells[j].indexOf("_.")==0) {ttag="th";cells[j]=cells[j].substring(2);}
				cells[j]=prep(cells[j]);
				var al=/^([<>=^~\/\\\{]+.*?)\.(.*)/.exec(cells[j]);
				var at="",st="";
				if(al != null) {
					cells[j]=al[2];
					var cs= /\\(\d+)/.exec(al[1]);if(cs != null){at +=qat('colspan',cs[1]);}
					var rs= /\/(\d+)/.exec(al[1]);if(rs != null){at +=qat('rowspan',rs[1]);}
					var va= /([\^~])/.exec(al[1]);if(va != null){st +="vertical-align:"+alg[va[1]]+";";}
					var ta= /(<>|=|<|>)/.exec(al[1]);if(ta != null){st +="text-align:"+alg[ta[1]]+";";}
					var is= /\{([^\}]+)\}/.exec(al[1]);if(is != null){st +=is[1];}
					if(st != ""){at+=qat('style',st);}					
				}
				trow += tag(ttag,at,cells[j]);
			}
			html += "\t"+tag("tr",rowst,trow)+"\n";
			continue;
		}
		if(intable) {html += "<\/table>"+le;intable=0;}

		if (lines[i]=="") {stp();}
		else if (!inpr) {
			if(mm=bq.exec(lines[i])){lines[i]=lines[i].replace(bq,"");html +="<blockquote>";inbq=1;if(mm[1]) {inbqq=1;}}
			html += "<p>"+prep(lines[i]);inpr=1;
		}
		else {html += prep(lines[i]);}
	}
	stp();
	return html;
}

function prep(m){
	for(i in ent) {m=m.replace(new RegExp(i,"g"),ent[i]);}
	for(i in tags) {
		m = make_tag(m,RegExp("^"+tags[i]+"(.+?)"+tags[i]),i,"");
		m = make_tag(m,RegExp(" "+tags[i]+"(.+?)"+tags[i]),i," ");
	}
	m=m.replace(/\[(\d+)\]/g,'<sup><a href="#fn$1">$1<\/a><\/sup>');
	m=m.replace(/([A-Z]+)\((.*?)\)/g,'<acronym title="$2">$1<\/acronym>');
	m=m.replace(/\"([^\"]+)\":((http|https|mailto):\S+)/g,'<a href="$2">$1<\/a>');
	m = make_image(m,/!([^!\s]+)!:(\S+)/);
	m = make_image(m,/!([^!\s]+)!/);
	m=m.replace(/"([^\"]+)":(\S+)/g,function($0,$1,$2){return tag("a",qat('href',aliases[$2]),$1)});
	m=m.replace(/(=)?"([^\"]+)"/g,function($0,$1,$2){return ($1)?$0:"&#8220;"+$2+"&#8221;"});
	return m;
}

function make_tag(s,re,t,sp) {
	while(m = re.exec(s)) {
		var st = make_attr(m[1]);
		m[1]=m[1].replace(/^[\[\{\(]\S+[\]\}\)]/g,"");
		m[1]=m[1].replace(/^[<>=()]+/,"");
		s = s.replace(re,sp+tag(t,st,m[1]));
	}
	return s;
}

function make_image(m,re) {
	var ma = re.exec(m);
	if(ma != null) {
		var attr="";var st="";
		var at = /\((.*)\)$/.exec(ma[1]);
		if(at != null) {attr = qat('alt',at[1])+qat("title",at[1]);ma[1]=ma[1].replace(/\((.*)\)$/,"");}
		if(ma[1].match(/^[><]/)) {st = "float:"+((ma[1].indexOf(">")==0)?"right;":"left;");ma[1]=ma[1].replace(/^[><]/,"");}
		var pdl = /(\(+)/.exec(ma[1]);if(pdl){st+="padding-left:"+pdl[1].length+"em;";}
		var pdr = /(\)+)/.exec(ma[1]);if(pdr){st+="padding-right:"+pdr[1].length+"em;";}
		if(st){attr += qat('style',st);}
		var im = '<img src="'+ma[1]+'"'+attr+" />";
		if(ma.length >2) {im=tag('a',qat('href',ma[2]),im);}
		m = m.replace(re,im);
	}
	return m;
}

function make_attr(s) {
	var st="";var at="";
	if(!s){return "";}
	var l=/\[(\w\w)\]/.exec(s);
	if(l != null) {at += qat('lang',l[1]);}
	var ci=/\((\S+)\)/.exec(s);
	if(ci != null) {
		s = s.replace(/\((\S+)\)/,"");
		at += ci[1].replace(/#(.*)$/,' id="$1"').replace(/^(\S+)/,' class="$1"');
	}
	var ta= /(<>|=|<|>)/.exec(s);if(ta){st +="text-align:"+alg[ta[1]]+";";}
	var ss=/\{(\S+)\}/.exec(s);if(ss){st += ss[1];if(!ss[1].match(/;$/)){st+= ";";}}
	var pdl = /(\(+)/.exec(s);if(pdl){st+="padding-left:"+pdl[1].length+"em;";}
	var pdr = /(\)+)/.exec(s);if(pdr){st+="padding-right:"+pdr[1].length+"em;";}
	if(st) {at += qat('style',st);}
	return at;
}

function qat(a,v){return ' '+a+'="'+v+'"';}
function tag(t,a,c) {return "<"+t+a+">"+c+"</"+t+">";}
function stp(b){if(b){inbqq=0;}if(inpr){html+="<\/p>"+le;inpr=0;}if(inbq && !inbqq){html+="<\/blockquote>"+le;inbq=0;}}
