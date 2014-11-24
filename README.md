Speak-Queue
===========

Queue up things for your Mac to say in different voices, from any app!

Intro
-----
Speak Queue is a Mac app (10.6+) that uses the built-in speech synthesier to read things to you.  Select text in almost any app and hit a systme-wide hotkey (user-customizable) and it starts speaking.  You can add more text to be spoken while it's still speaking.  Other hotkeys will bring up a pop-up with the different voices, so you can queue up a whole conversation!  You can also pause and resume speech mid-sentence. 

Queuing Up Text
---------------
To queue up text to speak, select text in any app and hit the hotkey (default Command-Control-J).  The text is added to the queue and will start speaking with the currently-selected voice.  You can select more text and add it with the same hotkey; they will be spoken in the order you added them.  This uses uses the system clipboard, so it will work with any app that recognizes Command-C as the copy command and copies text to the clipboard when Command-C is pressed.

To queue up text in different voices, use the Popup Enqueue hotkey (default Command-Option-Control-J).  This will bring up a popup window with the list of voices; select one and hit "Queue Up" to queue up the text in that voice.

If you have text in a movie-script-style format, i.e.:

    Jim: Bones, can you establish a cause of death?
    (Bones examines the body)
    Bones: I don't understand it, all the readings say this man should be perfectly healthy.
    Jim: Doctor, a member of my crew has died, I want to know why!
    Bones: Dammit, Jim, I'm a doctor, not a miracle-worker!

Then you can use the Script Enqueue to assign voices to the different characters.  Select all the text and hit the Script Enqueue hotkey (default Command-Option-Shift-J) and a popup will appear with the name of each character next to a pulldown to assign a voice to that character.  Speak Queue does this by looking for the first colon on each line and interpreting everything before that as a character's name; if it makes a mistake, such as if there's a line of stage direction with a colon in it, just select "(Not a Speaker)" as the voice for that "character".  The "(Narrator)" voice will be used speak any lines without a character.  If you tell it that (Narrator) is (Not a Speaker), then each line without a character name will be spoken by the last character to speak (and any such lines that come before the first character will be spoken in the currently-selected voice in from the main window).

Controlling Playback
--------------------
You can pause or resume speaking with the pause button in the main window, or set a global hotkey in the preferences.  The "rewind" button will restart the current piece fo text while the "fast-forward" button will skip to the next one.  Both of these functions can be assigned hotkeys.

Main Window
-----------
The main window contains a list of items currently in the queue, with the item currently being spoken at the top of the list.  The toolbar has a pulldown of voices and a rate slider to control how fast the voice speaks.  The slider setting is remembered separately for each voice.  The "X" button clears all items from the queue, including the one currently being spoken.  You can also select an individual item from the queue and press "delete" on the keyboard to remove that item from the queue.  The "Controls" buttons include a "rewind" button that restarts the current item, a pause/play button that will pause and resume speaking (items may be enqueued while speaking is paused), and a "fast-forward" button that will skip to the next item in the queue.

Preferences
-----------
You can open the preferences window with Command-comma, or selecting "Preferences…" from the Speak Queue menu.  There are three pages of preferences to set: General, Hotkeys, and Substitution.

General
-------
The General section of the Preferences offers the following options:

The "Reload Voices" button re-loads the list of voices available to the system.  Also resets the order of the voices.

The "Reset Speaking Rates" button resets the speaking rates of all the voices to the default, settable with the slider underneath it.

"Move voices to top when selected" moves a voice to the top of the list of voices when you choose that voice either in the main window or in one of the popups.  Useful if you want more recently-used voices nearer the top of the list.

"Newlines end sentences" puts a period after any hard-returns in the text.  Useful for lists and section headings that otherwise run into the text below them without any pause.

"Open popups at mouse" will open the Popup and Script Popup windows next to the mouse cursor each time you activate their respective hotkeys, rather than remembering where you last dragged them.

"Popup Enqueue with one click" will remove the "Queue Up" button from the Popup window and instead immediataly queue up the text and close the popup when you select a voice.

"Popup has rate slider" will add a rate slider to the Popup window, if you want to have it speak things at different rates using the popup.

Hotkeys
-------
The Hotkeys section of the Preferences is used to set the hotkeys for various functions.  Use the Set Key… button to choose a key combination to activat that function.

Substitution
------------
If the speech synthesizer is pronouncing something wrong, you may be able to help it with this panel.  Here you can tell it to replace instances of one word with another in any text you give it to read.  Click the + button to add a rule, and enter the text to replace and the text to replace it with, in the respective fields.  Check "Case" if you want the rule to be case-sensitive.
