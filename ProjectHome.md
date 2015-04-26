Plops is a lightweight widget engine that provides simple desktop widgets with a low memory footprint.   The memory footprint isn't nearly as small as it could be, but it is at least significantly better than other desktop widget engines.

Plops is inspired by adesklets and similarly uses imlib2 for drawing operations.
The main architectural difference between adesklets and plops, is that adesklets launched the widgets using stdin, stdout and stderr for communication.  plops uses named pipes.

Plops does not provide window alpha, non-rectangular windows are available with the window shape extension.