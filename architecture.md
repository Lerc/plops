Plops uses a text interface via named pipes.  At its most basic level A widget need only send drawing instructions to the command's pipe.  The events pipe is not used until the widget sends a `start_events` command.  At it's most simplest, this means a non-interactive widget could be implemented using `cron` and `cat`.

This diagram shows the basic layout of the intended operation of plops.
![http://plops.googlecode.com/svn/wiki/images/plops_architecture.png](http://plops.googlecode.com/svn/wiki/images/plops_architecture.png)

Windows are dragable by default to receive click events instead of dragging the widget, you send a `set_event_mask` command which loads a mask from the current images alpha channel.  Any solid areas in the image become clickable zones and events will be sent via the event pipe.  Any clicks elsewhere on the widget will drag it as before.

The `set_shape` command performs a similar operation using the currnent image's alpha channel only this uses the X Windows Shape Extension to change the shape of the window.  This mechanism does not provide variable levels of transparency, but it also means a compositing window manager is not required.

The observant of you may notice that there is a results pipe,  Currently, there are no result returning functions in plops, but when I add them, results will be passed via this pipe.