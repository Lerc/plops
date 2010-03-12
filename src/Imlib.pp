
unit Imlib;  {actually Imlib2 but We're going to pretend this is the ony one}
interface
{$LINKLIB Imlib2}

uses
  BaseUnix,X,xlib;

{
  Automatically converted by H2Pas 1.0.0 from Imlib2.h
  The following command line parameters were used:
    -T
    -C
    -p
    -d
    -l
    /usr/lib/libImlib2.so
    Imlib2.ht
}


{
  Type
  PByte  = ^Byte;
  Pcfloat  = ^cfloat;
  PDisplay  = ^Display;
  Pborder  = ^border;
  Pcolor  = ^color;
  PColor_Modifier  = ^Color_Modifier;
  PColor_Range  = ^Color_Range;
  PContext  = ^Context;
  PFilter  = ^Filter;
  PFont  = ^Font;
  PImage  = ^Image;
  Pload_error  = ^load_error;
  Poperation  = ^operation;
  Ptext_direction  = ^text_direction;
  PTTF_encoding  = ^TTF_encoding;
  PUpdates  = ^Updates;
  PImlibLoadError  = ^ImlibLoadError;
  PImlibPolygon  = ^ImlibPolygon;
  PLongWord  = ^LongWord;
  PPixmap  = ^Pixmap;
  PVisual  = ^Visual;
  PXImage  = ^XImage;
}  
{$IFDEF FPC}
{$PACKRECORDS C}
{$ENDIF}


{$ifndef __API_H}

  const
     __API_H = 1;     
  { opaque data types  }

  type
		 ppchar = ^pChar;
     PContext = ^TContext;
     TContext = pointer;

     PImage = ^TImage;
     TImage = pointer;

     PColor_Modifier = ^TColor_Modifier;
     TColor_Modifier = pointer;

     PUpdates = ^TUpdates;
     TUpdates = pointer;

     PFont = ^TFont;
     TFont = pointer;

     PColor_Range = ^TColor_Range;
     TColor_Range = pointer;

     PFilter = ^TFilter;
     TFilter = pointer;

     PImlibPolygon = ^TImlibPolygon;
     TImlibPolygon = pointer;
  { blending operations  }
     Toperation = (OP_COPY,OP_ADD,OP_SUBTRACT,
       OP_RESHADE);

     Ttext_direction = (TEXT_TO_RIGHT := 0,TEXT_TO_LEFT := 1,
       TEXT_TO_DOWN := 2,TEXT_TO_UP := 3,
       TEXT_TO_ANGLE := 4);

     Tload_error = (LOAD_ERROR_NONE,LOAD_ERROR_FILE_DOES_NOT_EXIST,
       LOAD_ERROR_FILE_IS_DIRECTORY,
       LOAD_ERROR_PERMISSION_DENIED_TO_READ,
       LOAD_ERROR_NO_LOADER_FOR_FILE_FORMAT,
       LOAD_ERROR_PATH_TOO_LONG,LOAD_ERROR_PATH_COMPONENT_NON_EXISTANT,
       LOAD_ERROR_PATH_COMPONENT_NOT_DIRECTORY,
       LOAD_ERROR_PATH_POINTS_OUTSIDE_ADDRESS_SPACE,
       LOAD_ERROR_TOO_MANY_SYMBOLIC_LINKS,
       LOAD_ERROR_OUT_OF_MEMORY,LOAD_ERROR_OUT_OF_FILE_DESCRIPTORS,
       LOAD_ERROR_PERMISSION_DENIED_TO_WRITE,
       LOAD_ERROR_OUT_OF_DISK_SPACE,
       LOAD_ERROR_UNKNOWN);

  { Encodings known to Imlib2 (so far)  }
     TTTF_encoding = (TTF_ENCODING_ISO_8859_1,TTF_ENCODING_ISO_8859_2,
       TTF_ENCODING_ISO_8859_3,TTF_ENCODING_ISO_8859_4,
       TTF_ENCODING_ISO_8859_5);


     POperation = ^TOperation;
     //TOperation = Toperation;

     PLoad_Error = ^TLoad_Error;
     //TLoad_Error = Tload_error;

     PImlibLoadError = ^TImlibLoadError;
     TImlibLoadError = Tload_error;

     PText_Direction = ^TText_Direction;
     //TText_Direction = Ttext_direction;

     PTTF_Encoding = ^TTTF_Encoding;
     //TTTF_Encoding = TTTF_encoding;
     Pborder = ^Tborder;
     Tborder = record
          left : cint;
          right : cint;
          top : cint;
          bottom : cint;
       end;

     Pcolor = ^Tcolor;
     Tcolor = record
          alpha : cint;
          red : cint;
          green : cint;
          blue : cint;
       end;

  { Progressive loading callbacks  }

     TProgress_Function = function (im:TImage; percent:cchar; update_x:cint; update_y:cint; update_w:cint; 
                  update_h:cint):cint;cdecl;

     TData_Destructor_Function = procedure (im:TImage; data:pointer);cdecl;
  { context handling  }

  function context_new:TContext;cdecl;external name  'imlib_context_new';

  procedure context_free(context:TContext);cdecl;external name  'imlib_context_free';

  procedure context_push(context:TContext);cdecl;external name  'imlib_context_push';

  procedure context_pop;cdecl;external name  'imlib_context_pop';

  function context_get:TContext;cdecl;external name  'imlib_context_get';

  { context setting  }
{$ifndef X_DISPLAY_MISSING}

  procedure context_set_display(display:PDisplay);cdecl;external name  'imlib_context_set_display';

  procedure context_disconnect_display;cdecl;external name  'imlib_context_diconnect_display';

  procedure context_set_visual(visual:PVisual);cdecl;external name  'imlib_context_set_visual';

  procedure context_set_colormap(colormap:TColormap);cdecl;external name  'imlib_context_set_colormap';

  procedure context_set_drawable(drawable:TDrawable);cdecl;external name  'imlib_context_set_drawable';

  procedure context_set_mask(mask:TPixmap);cdecl;external name  'imlib_context_set_mask';

{$endif}

  procedure context_set_dither_mask(dither_mask:cchar);cdecl;external name  'imlib_context_set_dither_mask';

  procedure context_set_mask_alpha_threshold(mask_alpha_threshold:cint);cdecl;external name  'imlib_context_set_mask_alpha_threshod';

  procedure context_set_anti_alias(anti_alias:cchar);cdecl;external name  'imlib_context_set_anti_alias';

  procedure context_set_dither(dither:cchar);cdecl;external name  'imlib_context_set_dither';

  procedure context_set_blend(blend:cchar);cdecl;external name  'imlib_context_set_blend';

  procedure context_set_color_modifier(color_modifier:TColor_Modifier);cdecl;external name  'imlib_context_set_color_modifier';

  procedure context_set_operation(operation:TOperation);cdecl;external name  'imlib_context_set_operation';

  procedure context_set_font(font:TFont);cdecl;external name  'imlib_context_set_font';

  procedure context_set_direction(direction:TText_Direction);cdecl;external name  'imlib_context_set_direction';

  procedure context_set_angle(angle:Double);cdecl;external name  'imlib_context_set_angle';

  procedure context_set_color(red:cint; green:cint; blue:cint; alpha:cint);cdecl;external name  'imlib_context_set_color';

  procedure context_set_color_hsva(hue:cfloat; saturation:cfloat; value:cfloat; alpha:cint);cdecl;external name  'imlib_context_set_color_hsva';

  procedure context_set_color_hlsa(hue:cfloat; lightness:cfloat; saturation:cfloat; alpha:cint);cdecl;external name  'imlib_context_set_color_hlsa';

  procedure context_set_color_cmya(cyan:cint; magenta:cint; yellow:cint; alpha:cint);cdecl;external name  'imlib_context_set_color,cmya';

  procedure context_set_color_range(color_range:TColor_Range);cdecl;external name  'imlib_context_set_color_range';

  procedure context_set_progress_function(progress_function:TProgress_Function);cdecl;external name  'imlib_context_set_progress_function';

  procedure context_set_progress_granularity(progress_granularity:cchar);cdecl;external name  'imlib_context_set_progress_granularity';

  procedure context_set_image(image:TImage);cdecl;external  name  'imlib_context_set_image';

  procedure context_set_cliprect(x:cint; y:cint; w:cint; h:cint);cdecl;external  name  'imlib_context_set_cliprect';

  procedure context_set_TTF_encoding(encoding:TTTF_Encoding);cdecl;external name  'imlib_context_set_TTF_encoding';

  { context getting  }
{$ifndef X_DISPLAY_MISSING}

  function context_get_display:PDisplay;cdecl;external name  'imlib_context_get_display';

  function context_get_visual:PVisual;cdecl;external name  'imlib_context_get_visual' ;

  function context_get_colormap:TColormap;cdecl;external name  'imlib_context_get_colormap';

  function context_get_drawable:TDrawable;cdecl;external name  'imlib_context_get_drawable';

  function context_get_mask:TPixmap;cdecl;external name  'imlib_context_get_mask';

{$endif}

  function context_get_dither_mask:cchar;cdecl;external name  'imlib_context_get_dither_mask';

  function context_get_anti_alias:cchar;cdecl;external name  'imlib_context_get_anti_alias';

  function context_get_mask_alpha_threshold:cint;cdecl;external name  'imlib_context_get_mask_alpha_threshold';

  function context_get_dither:cchar;cdecl;external name  'imlib_context_get_diher';

  function context_get_blend:cchar;cdecl;external name  'imlib_context_get_blend';

  function context_get_color_modifier:TColor_Modifier;cdecl;external name  'imlib_context_get_color_modifier';

  function context_get_operation:TOperation;cdecl;external name  'imlib_context_get_operation';

  function context_get_font:TFont;cdecl;external name  'imlib_context_get_font';

  function context_get_angle:Double;cdecl;external name  'imlib_context_get_angle';

  function context_get_direction:TText_Direction;cdecl;external name  'imlib_context_get_direction';

  procedure context_get_color(var red:cint; var green:cint; var blue:cint; var alpha:cint);cdecl;external name  'imlib_context_get_color';

  procedure context_get_color_hsva(var hue:cfloat; var saturation:cfloat; var val:cfloat; var alpha:cint);cdecl;external name  'imlib_context_get_color_hsva';

  procedure context_get_color_hlsa(var hue:cfloat; var lightness:cfloat; var saturation:cfloat; var alpha:cint);cdecl;external name  'imlib_context_get_color_hlsa';

  procedure context_get_color_cmya(var cyan:cint; var magenta:cint; var yellow:cint; var alpha:cint);cdecl;external name  'imlib_context_get_color_cmya';

  function context_get_color:PColor;cdecl;external name  'imlib_context_get_color';

  function context_get_color_range:TColor_Range;cdecl;external name  'imlib_context_get_color_range';

  function context_get_progress_function:TProgress_Function;cdecl;external name  'imlib_context_get_progress_function';

  function context_get_progress_granularity:cchar;cdecl;external name  'imlib_context_get_progress_granularity';

  function context_get_image:TImage;cdecl;external name  'imlib_context_get_image';

  procedure context_get_cliprect(x:pcint; y:pcint; w:pcint; h:pcint);cdecl;external name  'imlib_context_get_cliprect';

  function context_get_TTF_encoding:TTTF_Encoding;cdecl;external name  'imlib_context_get_TTF_encoding';

  function get_cache_size:cint;cdecl;external name  'imlib_get_cache_size';

  procedure set_cache_size(bytes:cint);cdecl;external name  'imlib_set_cache_size';

  function get_color_usage:cint;cdecl;external name  'imlib_get_color_usage';

  procedure set_color_usage(max:cint);cdecl;external name  'imlib_set_color_usage';

  procedure flush_loaders;cdecl;external name  'imlib_flush_loaders';

{$ifndef X_DISPLAY_MISSING}

  function get_visual_depth(display:PDisplay; visual:PVisual):cint;cdecl;external name  'imlib_get_visual_depth';

  function get_best_visual(display:PDisplay; screen:cint;var depth_return:pcint):PVisual;cdecl;external name  'imlib_get_best_visual';

{$endif}
  function load_image(filename:pchar):TImage;cdecl;external name  'imlib_load_image';

  function load_image_immediately(filenmae:pchar):TImage;cdecl;external name  'imlib_load_image_immediately';

  function load_image_without_cache(filename:pchar):TImage;cdecl;external name  'imlib_load_image_without_cache';

  function load_image_immediately_without_cache(filename:pchar):TImage;cdecl;external name  'imlib_load_image_immediately_without_cache';

  function load_image_with_error_return(filename:pchar; var error_return:tLoad_Error):TImage;cdecl;external name  'imlib_load_image_with_error_return';

  procedure free_image;cdecl;external name  'imlib_free_image';

  procedure free_image_and_decache;cdecl;external name  'imlib_free_image_and_decache';

  { query/modify image parameters  }
  function image_get_width:cint;cdecl;external name  'imlib_image_get_width';

  function image_get_height:cint;cdecl;external name  'imlib_image_get_height';

(* Const before type ignored *)
  function image_get_filename:pchar;cdecl;external name  'imlib_image_get_filename';

  function image_get_data:PLongWord;cdecl;external name  'imlib_image_get_data';

  function image_get_data_for_reading_only:PLongWord;cdecl;external name  'imlib_image_get_data_for_reading_only';

  procedure image_put_back_data(data:PLongWord);cdecl;external name  'imlib_image_put_bak_data';

  function image_has_alpha:pchar;cdecl;external name  'imlib_image_has_alpha';

  procedure image_set_changes_on_disk;cdecl;external name  'imlib_image_set_changes_on_disk';

  procedure image_get_border(border:PBorder);cdecl;external name  'imlib_image_get_border';

  procedure image_set_border(border:PBorder);cdecl;external name  'imlib_image_set_border';

(* Const before type ignored *)
  procedure image_set_format(format:pchar);cdecl;external name  'imlib_image_set_format';

  procedure image_set_irrelevant_format(irrelevant:cchar);cdecl;external name  'imlib_image_set_irrelevant_format';

  procedure image_set_irrelevant_border(irrelevant:cchar);cdecl;external name  'imlib_image_set_irrelevant_border';

  procedure image_set_irrelevant_alpha(irrelevant:cchar);cdecl;external name  'imlib_image_set_irrelevant_alpha';

  function image_format:pchar;cdecl;external name  'imlib_image_format';

  procedure image_set_has_alpha(has_alpha:cchar);cdecl;external name  'imlib_image_set_has_alpha';

  procedure image_query_pixel(x:cint; y:cint;var color_return:tColor);cdecl;external name  'imlib_image_query_pixel';

  procedure image_query_pixel_hsva(x:cint; y:cint; var hue:cfloat; var saturation:cfloat; var val:cfloat; 
              var alpha:cint);cdecl;external name  'imlib_image_query_pixel_hsva';

  procedure image_query_pixel_hlsa(x:cint; y:cint; var hue:cfloat; var lightness:cfloat; var saturation:cfloat; 
              var alpha:cint);cdecl;external name  'imlib_image_query_pixel_hlsa';

  procedure image_query_pixel_cmya(x:cint; y:cint; var cyan:cint; var magenta:cint; var yellow:cint; 
              var alpha:cint);cdecl;external name  'imlib_image_cmya';

  { rendering functions  }
{$ifndef X_DISPLAY_MISSING}

  procedure render_pixmaps_for_whole_image(pixmap_return:PPixmap; mask_return:PPixmap);cdecl;external name  'imlib_render_pixmaps_for_whole_image';

  procedure render_pixmaps_for_whole_image_at_size(pixmap_return:PPixmap; mask_return:PPixmap; width:cint; height:cint);cdecl;external name  'imlib_render_pixmaps_for_whole_image_at_size';

  procedure free_pixmap_and_mask(pixmap:TPixmap);cdecl;external name  'imlib_free_pixmap_and_mask';

  procedure render_image_on_drawable(x:cint; y:cint);cdecl;external name  'imlib_render_image_on_drawable';

  procedure render_image_on_drawable_at_size(x:cint; y:cint; width:cint; height:cint);cdecl;
            external name  'imlib_render_image_on_drawable_at_size';

  procedure render_image_part_on_drawable_at_size(source_x:cint; source_y:cint; source_width:cint; source_height:cint; x:cint; 
              y:cint; width:cint; height:cint);cdecl;external name  'imlib_render_image_part_on_drawable_at_size';

  function render_get_pixel_color:LongWord;cdecl;external name  'imlib_render_get_pixel_color';

{$endif}

  procedure blend_image_onto_image(source_image:TImage; merge_alpha:cchar; source_x:cint; source_y:cint; source_width:cint; 
              source_height:cint; destination_x:cint; destination_y:cint; destination_width:cint; destination_height:cint);cdecl;external name  'imlib_blend_image_onto_image';

  { creation functions  }
  function create_image(width:cint; height:cint):TImage;cdecl;external name  'imlib_create_image';

  function create_image_using_data(width:cint; height:cint; data:PLongWord):TImage;cdecl;external name  'imlib_create_image_using_data';

  function create_image_using_copied_data(width:cint; height:cint; data:PLongWord):TImage;cdecl;external name  'imlib_create_image_using_copied_data';

{$ifndef X_DISPLAY_MISSING}

  function create_image_from_drawable(mask:TPixmap; x:cint; y:cint; width:cint; height:cint; 
             need_to_grab_x:cchar):TImage;cdecl;external name  'imlib_create_image_from_drawable';

  function create_image_from_ximage(image:PXImage; mask:PXImage; x:cint; y:cint; width:cint; 
             height:cint; need_to_grab_x:cchar):TImage;cdecl;external name  'imlib_create_image_from_ximage';

  function create_scaled_image_from_drawable(mask:TPixmap; source_x:cint; source_y:cint; source_width:cint; source_height:cint; 
             destination_width:cint; destination_height:cint; need_to_grab_x:cchar; get_mask_from_shape:cchar):TImage;cdecl;external name  'imlib_create_scaled_image_from_drawable';

  function copy_drawable_to_image(mask:TPixmap; x:cint; y:cint; width:cint; height:cint; 
             destination_x:cint; destination_y:cint; need_to_grab_x:cchar):cchar;cdecl;external name  'imlib_copy_drawable_to_image';

{$endif}

  function clone_image:TImage;cdecl;external name  'imlib_clone_image';

  function create_cropped_image(x:cint; y:cint; width:cint; height:cint):TImage;cdecl;external name  'imlib_create_cropped_image';

  function create_cropped_scaled_image(source_x:cint; source_y:cint; source_width:cint; source_height:cint; destination_width:cint; 
             destination_height:cint):TImage;cdecl;external name  'imlib_create_cropped_scaled_image';

  { imlib updates. lists of rectangles for storing required update draws  }
  function updates_clone(updates:TUpdates):TUpdates;cdecl;external name  'imlib_updates_clone';

  function update_append_rect(updates:TUpdates; x:cint; y:cint; w:cint; h:cint):TUpdates;cdecl;external name  'imlib_update_append_rect_';

  function updates_merge(updates:TUpdates; w:cint; h:cint):TUpdates;cdecl;external name  'imlib_updates_merge';

  function updates_merge_for_rendering(updates:TUpdates; w:cint; h:cint):TUpdates;cdecl;external name  'imlib_updates_merge_for_rendering';

  procedure updates_free(updates:TUpdates);cdecl;external  name  'imlib_updates_free';

  function updates_get_next(updates:TUpdates):TUpdates;cdecl;external name  'imlib_updates_get_next';

  procedure updates_get_coordinates(updates:TUpdates; x_return:pcint; y_return:pcint; width_return:pcint; height_return:pcint);cdecl;external name  'imlib_updates_get_coodinates';

  procedure updates_set_coordinates(updates:TUpdates; x:cint; y:cint; width:cint; height:cint);cdecl;external name  'imlib_set_coordinates';

  procedure render_image_updates_on_drawable(updates:TUpdates; x:cint; y:cint);cdecl;external name  'imlib_render_image_updates_on_drawable';

  function updates_init:TUpdates;cdecl;external name  'imlib_updtes_init';

  function updates_append_updates(updates:TUpdates; appended_updates:TUpdates):TUpdates;cdecl;external name  'imlib_updates_append_updates';

  { image modification  }
  procedure image_flip_horizontal;cdecl;external name  'imlib_image_flip_horizontal';

  procedure image_flip_vertical;cdecl;external name  'imlib_image_flip_vertical';

  procedure image_flip_diagonal;cdecl;external name  'imlib_image_flip_diagonal';

  procedure image_orientate(orientation:cint);cdecl;external name  'imlib_image_orientate';

  procedure image_blur(radius:cint);cdecl;external name  'imlib_image_blur';

  procedure image_sharpen(radius:cint);cdecl;external name  'imlib_image_sharpen';

  procedure image_tile_horizontal;cdecl;external name  'imlib_image_tile_horizontal';

  procedure image_tile_vertical;cdecl;external name  'imlib_image_tile_vertical';

  procedure image_tile;cdecl;external name  'imlib_image_tile';

  { fonts and text  }
(* Const before type ignored *)
  function load_font(font_name:pchar):TFont;cdecl;external name  'imlib_load_font';

  procedure free_font; cdecl;external name  'imlib_free_font';

  { NB! The four functions below are deprecated.  }
  function insert_font_into_fallback_chain(font:TFont; fallback_font:TFont):cint;cdecl;external name  'imlib_inserf_font_into_failback_chain';

  procedure remove_font_from_fallback_chain(fallback_font:TFont);cdecl;external name  'imlib_remove_font_from_failback_chain';

  function get_prev_font_in_fallback_chain(fn:TFont):TFont;cdecl;external name  'imlib_get_prev_font_in_failaback_chain';

  function get_next_font_in_fallback_chain(fn:TFont):TFont;cdecl;external name  'imlib_get_next_font_in_failback_chain';

  { NB! The four functions above are deprecated.  }
(* Const before type ignored *)
  procedure text_draw(x:cint; y:cint; text:pchar);cdecl;external name  'imlib_text_draw';

(* Const before type ignored *)
  procedure text_draw_with_return_metrics(x:cint; y:cint; text:pchar; width_return:pcint; height_return:pcint; 
              horizontal_advance_return:pcint; vertical_advance_return:pcint);cdecl;external name  'imlib_Text_draw_with_return_metrics';

(* Const before type ignored *)
  procedure get_text_size(text:pchar; width_return:pcint; height_return:pcint);cdecl;external name  'imlib_get_text_size';

(* Const before type ignored *)
  procedure get_text_advance(text:pchar; horizontal_advance_return:pcint; vertical_advance_return:pcint);cdecl;external name  'imlib_get_text_advance';

(* Const before type ignored *)
  function get_text_inset(text:pchar):cint;cdecl;external name  'imlib_get_text_insert';

(* Const before type ignored *)
  procedure add_path_to_font_path(path:pchar);cdecl;external name  'imlib_add_path_to_font_path';

(* Const before type ignored *)
  procedure remove_path_from_font_path(path:pchar);cdecl;external name  'imlib_remove_path_from_font_path';

  function list_font_path(var number_return:cint):ppchar;cdecl;external name  'imlib_list_font_path';

(* Const before type ignored *)
  function text_get_index_and_location(text:pchar; x:cint; y:cint; char_x_return:pcint; char_y_return:pcint; 
             char_width_return:pcint; char_height_return:pcint):cint;cdecl;external name  'imlib_text_get_index_and_location';

(* Const before type ignored *)
  procedure text_get_location_at_index(text:pchar; index:cint; char_x_return:pcint; char_y_return:pcint; char_width_return:pcint; 
              char_height_return:pcint);cdecl;external name  'imlib_text_get_location_at_index';

  function list_fonts(number_return:pcint):ppchar;cdecl;external name  'imlib_list_fonts';

  procedure free_font_list(font_list:Ppchar; number:cint);cdecl;external name  'imlib_free_fonts_list';

  function get_font_cache_size:cint;cdecl;external name  'imlib_get_font_cache_size';

  procedure set_font_cache_size(bytes:cint);cdecl;external name  'imlib_set_font_cache_size';

  procedure flush_font_cache;cdecl;external name  'imlib_flush_font_cache';

  function get_font_ascent:cint;cdecl;external name  'imlib_get_font_ascent';

  function get_font_descent:cint;cdecl;external name  'imlib_get_font_descent';

  function get_maximum_font_ascent:cint;cdecl;external name  'imlib_get_maximum_font_ascent';

  function get_maximum_font_descent:cint;cdecl;external name  'imlib_get_maximum_font_descent';

  { color modifiers  }
  function create_color_modifier:TColor_Modifier;cdecl;external name  'imlib_create_color_modifier';

  procedure free_color_modifier;cdecl;external name  'imlib_free_color_modifier';

  procedure modify_color_modifier_gamma(gamma_value:Double);cdecl;external name  'imlib_modify_color_modifier_gamma';

  procedure modify_color_modifier_brightness(brightness_value:Double);cdecl;external name  'imlib_modify_colour_modifier_brightness';

  procedure modify_color_modifier_contrast(contrast_value:Double);cdecl;external name  'imlib_modify_color_modifier_contrast';

  procedure set_color_modifier_tables(red_table:PByte; green_table:PByte; blue_table:PByte; alpha_table:PByte);cdecl;external name  'imlib_set_color_modifier_tables';

  procedure get_color_modifier_tables(red_table:PByte; green_table:PByte; blue_table:PByte; alpha_table:PByte);cdecl;external name  'imlib_get_color_modifier_table';

  procedure reset_color_modifier;cdecl;external name  'imlib_reset_color_modifier';

  procedure apply_color_modifier;cdecl;external name  'imlib_apply_color_modifier';

  procedure apply_color_modifier_to_rectangle(x:cint; y:cint; width:cint; height:cint);cdecl;external name  'imlib_apply_colour_modifier_to_rectangle';

  { drawing on images  }
  function image_draw_pixel(x:cint; y:cint; make_updates:cchar):TUpdates;cdecl;external name  'imlib_draw_pixel';

  function image_draw_line(x1:cint; y1:cint; x2:cint; y2:cint; make_updates:cchar):TUpdates;cdecl;external name  'imlib_image_draw_line';

  function clip_line(x0:cint; y0:cint; x1:cint; y1:cint; xmin:cint; 
             xmax:cint; ymin:cint; ymax:cint; clip_x0:pcint; clip_y0:pcint; 
             clip_x1:pcint; clip_y1:pcint):cint;cdecl;external name  'imlib_clip_line';

  procedure image_draw_rectangle(x:cint; y:cint; width:cint; height:cint);cdecl;external name  'imlib_image_draw_rectangle';

  procedure image_fill_rectangle(x:cint; y:cint; width:cint; height:cint);cdecl;external name  'imlib_image_fill_rectangle';

  procedure image_copy_alpha_to_image(image_source:TImage; x:cint; y:cint);cdecl;external name  'imlib_image_copy_alpha_to_image';

  procedure image_copy_alpha_rectangle_to_image(image_source:TImage; x:cint; y:cint; width:cint; height:cint; 
              destination_x:cint; destination_y:cint);cdecl;external name  'imlib_image_copy_alpha_rectangle_to_image';

  procedure image_scroll_rect(x:cint; y:cint; width:cint; height:cint; delta_x:cint; 
              delta_y:cint);cdecl;external name  'imlib_image_scroll_rect';

  procedure image_copy_rect(x:cint; y:cint; width:cint; height:cint; new_x:cint; 
              new_y:cint);cdecl;external name  'imlib_image_copy_rect';

  { polygons  }
  function polygon_new:TImlibPolygon;cdecl;external name  'imlib_polygon_new';

  procedure polygon_free(poly:TImlibPolygon);cdecl;external name  'imlib_polygon_free';

  procedure polygon_add_point(poly:TImlibPolygon; x:cint; y:cint);cdecl;external name  'imlib_polygon_add_point';

  procedure image_draw_polygon(poly:TImlibPolygon; closed:cuchar);cdecl;external name  'imlib_image_draw_polygon';

  procedure image_fill_polygon(poly:TImlibPolygon);cdecl;external name  'imlib_image_fill_polygon';

  procedure polygon_get_bounds(poly:TImlibPolygon; px1:pcint; py1:pcint; px2:pcint; py2:pcint);cdecl;external name  'imlib_polygon_get_bounds';

  function polygon_contains_point(poly:TImlibPolygon; x:cint; y:cint):cuchar;cdecl;external name  'imlib_polygon_contains_point';

  { ellipses  }
  procedure image_draw_ellipse(xc:cint; yc:cint; a:cint; b:cint);cdecl;external name  'imlib_image_draw_ellipse';
  

  procedure image_fill_ellipse(xc:cint; yc:cint; a:cint; b:cint);cdecl;external name  'imlib_image_fill_ellipse';

  { color ranges  }
  function create_color_range:TColor_Range;cdecl;external name  'imlib_image_create_color_range';

  procedure free_color_range;cdecl;external name  'imlib_free_color_range';

  procedure add_color_to_color_range(distance_away:cint);cdecl;external name  'imlib_add_color_to_color_range';

  procedure image_fill_color_range_rectangle(x:cint; y:cint; width:cint; height:cint; angle:Double);cdecl;external name  'imlib_image_fill_color_range_rectangle';

  procedure image_fill_hsva_color_range_rectangle(x:cint; y:cint; width:cint; height:cint; angle:Double);cdecl;external name  'imlib_image_fill_hsva_color_range';

  { image data  }
(* Const before type ignored *)
  procedure image_attach_data_value(key:pchar; data:pointer; value:cint; destructor_function:TData_Destructor_Function);cdecl;external name  'imlib_image_attach_data_value';
  

(* Const before type ignored *)
  function image_get_attached_data(key:pchar):pointer;cdecl;external name  'imlib_image_get_attached_data';

(* Const before type ignored *)
  function image_get_attached_value(key:pchar):cint;cdecl;external name  'imlib_image_get_attached_value';

(* Const before type ignored *)
  procedure image_remove_attached_data_value(key:pchar);cdecl;external name  'imlib_image_remove_attached_data_value';

(* Const before type ignored *)
  procedure image_remove_and_free_attached_data_value(key:pchar);cdecl;external name  'imlib_image_remove_and_fre_attached_data_value';

  { saving  }
(* Const before type ignored *)
  procedure save_image(filename:pchar);cdecl;external name  'imlib_save_image';

(* Const before type ignored *)
  procedure save_image_with_error_return(filename:pchar; error_return:PLoad_Error);cdecl;external name  'imlib_save_image_with_error_return';

  { FIXME:  }
  { need to add arbitary rotation routines  }
  { rotation/skewing  }
  function create_rotated_image(angle:Double):TImage;cdecl;external name  'imlib_create_rotated_image';

  { rotation from buffer to context (without copying) }
  procedure rotate_image_from_buffer(angle:Double; source_image:TImage);cdecl;external name  'imlib_';

  procedure blend_image_onto_image_at_angle(source_image:TImage; merge_alpha:cchar; source_x:cint; source_y:cint; source_width:cint; 
              source_height:cint; destination_x:cint; destination_y:cint; angle_x:cint; angle_y:cint);cdecl;external name  'imlib_blendimage_onto_image_at_angle';

  procedure blend_image_onto_image_skewed(source_image:TImage; merge_alpha:cchar; source_x:cint; source_y:cint; source_width:cint; 
              source_height:cint; destination_x:cint; destination_y:cint; h_angle_x:cint; h_angle_y:cint; 
              v_angle_x:cint; v_angle_y:cint);cdecl;external  name  'imlib_blend_image_onto_image_skewed';

{$ifndef X_DISPLAY_MISSING}

  procedure render_image_on_drawable_skewed(source_x:cint; source_y:cint; source_width:cint; source_height:cint; destination_x:cint; 
              destination_y:cint; h_angle_x:cint; h_angle_y:cint; v_angle_x:cint; v_angle_y:cint);cdecl;external name  'imlib_render_image_on_drawable_skewed';

  procedure render_image_on_drawable_at_angle(source_x:cint; source_y:cint; source_width:cint; source_height:cint; destination_x:cint; 
              destination_y:cint; angle_x:cint; angle_y:cint);cdecl;external name  'imlib_render_image_on_drawable_at_angle';

{$endif}
  { image filters  }

  procedure image_filter;cdecl;external name  'imlib_image_filter';

  function create_filter(initsize:cint):TFilter;cdecl;external name  'imlib_create_filter';

  procedure context_set_filter(filter:TFilter);cdecl;external name  'imlib_context_set_filter';

  function context_get_filter:TFilter;cdecl;external name  'imlib_context_get_filter';

  procedure free_filter;cdecl;external name  'imlib_free_filter';

  procedure filter_set(xoff:cint; yoff:cint; a:cint; r:cint; g:cint; 
              b:cint);cdecl;external name  'imlib_filter_set';

  procedure filter_set_alpha(xoff:cint; yoff:cint; a:cint; r:cint; g:cint; 
              b:cint);cdecl;external name  'imlib_filter_set_alpha';

  procedure filter_set_red(xoff:cint; yoff:cint; a:cint; r:cint; g:cint; 
              b:cint);cdecl;external name  'imlib_filter_set_red';

  procedure filter_set_green(xoff:cint; yoff:cint; a:cint; r:cint; g:cint; 
              b:cint);cdecl;external name  'imlib_filter_set_green';

  procedure filter_set_blue(xoff:cint; yoff:cint; a:cint; r:cint; g:cint; 
              b:cint);cdecl;external name  'imlib_filter_set_blue';

  procedure filter_constants(a:cint; r:cint; g:cint; b:cint);cdecl;external name  'imlib_filter_constants';

  procedure filter_divisors(a:cint; r:cint; g:cint; b:cint);cdecl;external name  'imlib_filter_divisors';

//  procedure apply_filter(script:pchar; args:array of const);cdecl;external;

  procedure apply_filter(script:pchar);cdecl;external name  'imlib_apply_filter';

  procedure image_clear;cdecl;external name  'imlib_image_clear';

  procedure image_clear_color(r:cint; g:cint; b:cint; a:cint);cdecl;external name  'imlib_image_clear_color';

{$endif}

implementation


end.
