#' Knit a document
#'
#' This function takes an input file, extracts the R code in it according to a
#' list of patterns, evaluates the code and writes the output in another file.
#' It can also tangle R source code from the input document (\code{purl()} is a
#' wrapper to \code{knit(..., tangle = TRUE)}).
#'
#' For most of the time, it is not necessary to set any options outside the
#' input document; in other words, a single call like
#' \code{knit('my_input.Rnw')} is usually enough. This function will try to
#' determine many internal settings automatically. For the sake of
#' reproducibility, it is a better practice to include the options inside the
#' input document (to be self-contained), instead of setting them before
#' knitting the document.
#'
#' First the filename of the output document is determined in this way:
#' \file{foo.Rnw} generates \file{foo.tex}, and other filename extensions like
#' \file{.Rtex}, \file{.Rhtml} (\file{.Rhtm}) and \file{.Rmd}
#' (\file{.Rmarkdown}) will generate \file{.tex}, \file{.html} and \file{.md}
#' respectively. For other types of files, if the filename contains
#' \samp{_knit_}, this part will be removed in the output file, e.g.,
#' \file{foo_knit_.html} creates the output \file{foo.html}; if \samp{_knit_} is
#' not found in the filename, \file{foo.ext} will produce \file{foo.txt} if
#' \code{ext} is not \code{txt}, otherwise the output is \file{foo-out.txt}. If
#' \code{tangle = TRUE}, \file{foo.ext} generates an R script \file{foo.R}.
#'
#' We need a set of syntax to identify special markups for R code chunks and R
#' options, etc. The syntax is defined in a pattern list. All built-in pattern
#' lists can be found in \code{all_patterns} (call it \code{apat}). First
#' \pkg{knitr} will try to decide the pattern list based on the filename
#' extension of the input document, e.g. \samp{Rnw} files use the list
#' \code{apat$rnw}, \samp{tex} uses the list \code{apat$tex}, \samp{brew} uses
#' \code{apat$brew} and HTML files use \code{apat$html}; for unkown extensions,
#' the content of the input document is matched against all pattern lists to
#' automatically which pattern list is being used. You can also manually set the
#' pattern list using the \code{\link{knit_patterns}} object or the
#' \code{\link{pat_rnw}} series functions in advance and \pkg{knitr} will
#' respect the setting.
#'
#' According to the output format (\code{opts_knit$get('out.format')}), a set of
#' output hooks will be set to mark up results from R (see
#' \code{\link{render_latex}}). The output format can be LaTeX, Sweave and HTML,
#' etc. The output hooks decide how to mark up the results (you can customize
#' the hooks).
#'
#' See the package website and manuals in the references to know more about
#' \pkg{knitr}, including the full documentation of chunk options and demos,
#' etc.
#' @param input path of the input file
#' @param output path of the output file for \code{knit()}; if \code{NULL}, this
#'   function will try to guess and it will be under the current working
#'   directory
#' @param tangle whether to tangle the R code from the input file (like
#'   \code{\link[utils]{Stangle}})
#' @param text a character vector as an alternative way to provide the input
#'   file
#' @param quiet whether to suppress the progress bar and messages
#' @param envir the environment in which the code chunks are to be evaluated
#'   (for example, \code{\link{parent.frame}()}, \code{\link{new.env}()}, or
#'   \code{\link{globalenv}()})
#' @param encoding the encoding of the input file; see \code{\link{file}}
#' @return The compiled document is written into the output file, and the path
#'   of the output file is returned, but if the \code{output} path is
#'   \code{NULL}, the output is returned as a character vector.
#' @note The name \code{knit} comes from its counterpart \samp{weave} (as in
#'   Sweave), and the name \code{purl} (as \samp{tangle} in Stangle) comes from
#'   a knitting method `knit one, purl one'.
#'
#'   If the input document has child documents, they will also be compiled
#'   recursively. See \code{\link{knit_child}}.
#'
#'   The working directory when evaluating R code chunks is the directory of the
#'   input document by default, so if the R code involves external files (like
#'   \code{read.table()}), it is better to put these files under the same
#'   directory of the input document so that we can use relative paths. However,
#'   it is possible to change this directory with the package option
#'   \code{\link{opts_knit}$set(root.dir = ...)} so all paths in code chunks are
#'   relative to this \code{root.dir}.
#'
#'   The arguments \code{input} and \code{output} do not have to be restricted
#'   to files; they can be \code{stdin()}/\code{stdout()} or other types of
#'   connections, but the pattern list to read the input has to be set in
#'   advance (see \code{\link{pat_rnw}}), and the output hooks should also be
#'   set (see \code{\link{render_latex}}), otherwise \pkg{knitr} will try to
#'   guess the patterns and output format.
#'
#'   If the \code{output} argument is a file path, it is strongly recommended to
#'   be in the current working directory (e.g. \file{foo.tex} instead of
#'   \file{somewhere/foo.tex}), especially when the output has external
#'   dependencies such as figure files. If you want to write the output to a
#'   different directory, you are recommended to set the working directory to
#'   that directory before you knit a document. For example, if the source
#'   document is \file{foo.Rmd}, and the expected output is \file{out/foo.md},
#'   you can do \code{setwd('out/'); knit('../foo.Rmd')}, instead of
#'   \code{knit('foo.Rmd', 'out/foo.md')}.
#'
#'   N.B. There is no guarantee that the R script generated by \code{purl()} can
#'   reproduce the computation done in \code{knit()}. The \code{knit()} process
#'   can be fairly complicated (special values for chunk options, custom chunk
#'   hooks, computing engines besides R, and the \code{envir} argument, etc). If
#'   you want to reproduce the computation in a report generated by
#'   \code{knit()}, be sure to use \code{knit()}, instead of merely executing
#'   the R script generated by \code{purl()}. This seems to be obvious, but some
#'   people \href{http://bit.ly/SnLi6h}{just do not get it}.
#' @export
#' @references Package homepage: \url{http://yihui.name/knitr/}. The \pkg{knitr}
#'   \href{http://bit.ly/117OLVl}{main manual}: and
#'   \href{http://bit.ly/114GNdP}{graphics manual}.
#'
#'   See \code{citation('knitr')} for the citation information.
#' @examples library(knitr)
#' (f = system.file('examples', 'knitr-minimal.Rnw', package = 'knitr'))
#' knit(f)  # compile to tex
#'
#' purl(f)  # tangle R code
#' purl(f, documentation = 0)  # extract R code only
#' purl(f, documentation = 2)  # also include documentation
knit = function(input, output = NULL, tangle = FALSE, text = NULL, quiet = FALSE,
                envir = parent.frame(), encoding = getOption('encoding')) {

  # is input from a file? (or a connection on a file)
  in.file = !missing(input) &&
    (is.character(input) || prod(inherits(input, c('file', 'connection'), TRUE)))
  oconc = knit_concord$get(); on.exit(knit_concord$set(oconc), add = TRUE)
  # make a copy of the input path in input2 and change input to file path
  if (!missing(input)) input2 = input
  if (in.file && !is.character(input)) input = summary(input)$description

  if (child_mode()) {
    setwd(opts_knit$get('output.dir')) # always restore original working dir
    # in child mode, input path needs to be adjusted
    if (in.file && !is_abs_path(input)) {
      input = paste(opts_knit$get('child.path'), input, sep = '')
      input = input2 = file.path(input_dir(), input)
    }
    # respect the quiet argument in child mode (#741)
    optk = opts_knit$get(); on.exit(opts_knit$set(optk), add = TRUE)
    opts_knit$set(progress = opts_knit$get('progress') && !quiet)
  } else {
    opts_knit$set(output.dir = getwd()) # record working directory in 1st run
    knit_log$restore()
    on.exit(chunk_counter(reset = TRUE), add = TRUE) # restore counter
    adjust_opts_knit()
    # turn off fancy quotes, use smaller width
    oopts = options(
      useFancyQuotes = FALSE, width = opts_knit$get('width'),
      knitr.in.progress = TRUE, device = pdf_null
    )
    on.exit(options(oopts), add = TRUE)
    # restore chunk options after parent exits
    optc = opts_chunk$get(); on.exit(opts_chunk$restore(optc), add = TRUE)
    ocode = knit_code$get(); on.exit(knit_code$restore(ocode), add = TRUE)
    optk = opts_knit$get(); on.exit(opts_knit$set(optk), add = TRUE)
    opts_knit$set(tangle = tangle, encoding = encoding,
                  progress = opts_knit$get('progress') && !quiet
    )
  }
  # store the evaluation environment and restore on exit
  oenvir = .knitEnv$knit_global; .knitEnv$knit_global = envir
  on.exit({.knitEnv$knit_global = oenvir}, add = TRUE)

  ext = 'unknown'
  if (in.file) {
    input.dir = .knitEnv$input.dir; on.exit({.knitEnv$input.dir = input.dir}, add = TRUE)
    .knitEnv$input.dir = dirname(input) # record input dir
    ext = tolower(file_ext(input))
    if ((is.null(output) || is.na(output)) && !child_mode())
      output = basename(auto_out_name(input, ext))
    # do not run purl() when the output is newer than input (the output might
    # have been generated by hook_purl)
    if (is.character(output) && !child_mode()) {
      out.purl = sub_ext(input, 'R')
      if (tangle && file_test('-nt', out.purl, input)) return(out.purl)
      otangle = .knitEnv$tangle.file  # the tangled R script
      .knitEnv$tangle.file = normalizePath(out.purl, mustWork = FALSE)
      .knitEnv$tangle.start = FALSE
      on.exit({.knitEnv$tangle.file = otangle; .knitEnv$tangle.start = NULL}, add = TRUE)
    }
    if (is.null(getOption('tikzMetricsDictionary'))) {
      options(tikzMetricsDictionary = tikz_dict(input)) # cache tikz dictionary
      on.exit(options(tikzMetricsDictionary = NULL), add = TRUE)
    }
    knit_concord$set(infile = input, outfile = output)
  }

  encoding = correct_encode(encoding)
  text = if (is.null(text)) {
    readLines(if (is.character(input2)) {
      con = file(input2, encoding = encoding); on.exit(close(con), add = TRUE); con
    } else input2, warn = FALSE)
  } else split_lines(text) # make sure each element is one line
  if (!length(text)) {
    if (is.character(output)) file.create(output)
    return(output) # a trivial case: create an empty file and exit
  }
  text = native_encode(text)

  apat = all_patterns; opat = knit_patterns$get()
  on.exit(knit_patterns$restore(opat), add = TRUE)
  if (length(opat) == 0 || all(sapply(opat, is.null))) {
    # use ext if cannot auto detect pattern
    if (is.null(pattern <- detect_pattern(text, ext))) {
      # nothing to be executed; just return original input
      if (is.null(output)) return(paste(text, collapse = '\n')) else {
        cat(text, sep = '\n', file = output); return(output)
      }
    }
    if (!(pattern %in% names(apat)))
      stop("a pattern list cannot be automatically found for the file extension '",
           ext, "' in built-in pattern lists; ",
           'see ?knit_patterns on how to set up customized patterns')
    set_pattern(pattern)
    if (pattern == 'rnw' && length(sweave_lines <- which_sweave(text)) > 0)
      remind_sweave(if (in.file) input, sweave_lines)
    opts_knit$set(out.format = switch(
      pattern, rnw = 'latex', tex = 'latex', html = 'html', md = 'markdown',
      rst = 'rst', brew = 'brew', asciidoc = 'asciidoc', textile = 'textile'
    ))
  }

  if (is.null(out_format())) auto_format(ext)
  # in child mode, strip off the YAML metadata in Markdown if exists
  if (child_mode() && out_format('markdown') && grepl('^---\\s*$', text[1])) {
    i = grep('^---\\s*$', text)
    if (length(i) >= 2) text = text[-(1:i[2])]
  }
  # change output hooks only if they are not set beforehand
  if (identical(knit_hooks$get(names(.default.hooks)), .default.hooks) && !child_mode()) {
    getFromNamespace(paste('render', out_format(), sep = '_'), 'knitr')()
    on.exit(knit_hooks$set(.default.hooks), add = TRUE)
  }

  progress = opts_knit$get('progress')
  if (in.file && !quiet) message(ifelse(progress, '\n\n', ''), 'processing file: ', input)
  res = process_file(text, output)
  res = paste(knit_hooks$get('document')(res), collapse = '\n')
  if (!is.null(output))
    writeLines(if (encoding == '') res else native_encode(res, to = encoding),
               con = output, useBytes = encoding != '')
  if (!child_mode()) {
    dep_list$restore()  # empty dependency list
    .knitEnv$labels = NULL
  }

  if (in.file && is.character(output) && file.exists(output)) {
    concord_gen(input, output)
    if (!quiet) message('output file: ', output, ifelse(progress, '\n', ''))
  }

  output %n% res
}
#' @rdname knit
#' @param documentation an integer specifying the level of documentation to go
#'   the tangled script: \code{0} means pure code (discard all text chunks);
#'   \code{1} (default) means add the chunk headers to code; \code{2} means add
#'   all text chunks to code as roxygen comments
#' @param ... arguments passed to \code{\link{knit}()} from \code{purl()}
#' @export
purl = function(..., documentation = 1L) {
  doc = opts_knit$get('documentation'); on.exit(opts_knit$set(documentation = doc))
  opts_knit$set(documentation = documentation)
  knit(..., tangle = TRUE)
}

process_file = function(text, output) {
  groups = split_file(lines = text)
  n = length(groups); res = character(n); olines = integer(n)
  tangle = opts_knit$get('tangle')

  if (opts_knit$get('progress')) {
    pb = txtProgressBar(0, n, char = '.', style = 3)
    on.exit(close(pb), add = TRUE)
  }
  wd = getwd()
  for (i in 1:n) {
    if (!is.null(.knitEnv$terminate)) {
      res[i] = paste(.knitEnv$terminate, collapse = '\n')
      knit_exit(NULL)
      break  # must have called knit_exit(), so exit early
    }
    if (opts_knit$get('progress')) {
      setTxtProgressBar(pb, i)
      if (!tangle) cat('\n')  # under tangle mode, only show one progress bar
      flush.console()
    }
    group = groups[[i]]
    res[i] = withCallingHandlers(
      if (tangle) process_tangle(group) else process_group(group),
      error = function(e) {
        setwd(wd)
        cat(res, sep = '\n', file = output %n% '')
        message(
          'Quitting from lines ', paste(current_lines(i), collapse = '-'),
          ' (', knit_concord$get('infile'), ') '
        )
      }
    )
  }

  if (!tangle) res = insert_header(res)  # insert header
  # output line numbers
  if (concord_mode()) knit_concord$set(outlines = line_count(res))
  print_knitlog()
  if (tangle) res = res[res != '']

  res
}

auto_out_name = function(input, ext = tolower(file_ext(input))) {
  base = sans_ext(input)
  name = if (opts_knit$get('tangle')) c(base, '.R') else
    if (ext %in% c('rnw', 'snw')) c(base, '.tex') else
      if (ext %in% c('rmd', 'rmarkdown', 'rhtml', 'rhtm', 'rtex', 'stex', 'rrst', 'rtextile'))
        c(base, '.', substring(ext, 2L)) else
          if (grepl('_knit_', input)) sub('_knit_', '', input) else
            if (ext != 'txt') c(base, '.txt') else c(base, '-out.', ext)
  paste(name, collapse = '')
}

# determine output format based on file extension
ext2fmt = c(
  rnw = 'latex', snw = 'latex', tex = 'latex', rtex = 'latex', stex = 'latex',
  htm = 'html', html = 'html', rhtml = 'html', rhtm = 'html',
  md = 'markdown', markdown = 'markdown', rmd = 'markdown', rmarkdown = 'markdown',
  brew = 'brew', rst = 'rst', rrst = 'rst'
)

auto_format = function(ext) {
  fmt = ext2fmt[ext]
  if (is.na(fmt)) fmt = {
    warning('cannot automatically decide the output format')
    'unknown'
  }
  opts_knit$set(out.format = fmt)
  invisible(fmt)
}

#' Knit a child document
#'
#' This function knits a child document and returns a character string to input
#' the result into the main document. It is designed to be used in the chunk
#' option \code{child} and serves as the alternative to the
#' \command{SweaveInput} command in Sweave.
#' @param ... arguments passed to \code{\link{knit}}
#' @param options a list of chunk options to be used as global options inside
#'   the child document (ignored if not a list); when we use the \code{child}
#'   option in a parent chunk, the chunk options of the parent chunk will be
#'   passed to the \code{options} argument here
#' @inheritParams knit
#' @return A character string of the content of the compiled child document is
#'   returned as a character string so it can be written back to the parent
#'   document directly.
#' @references \url{http://yihui.name/knitr/demo/child/}
#' @note This function is not supposed be called directly like
#'   \code{\link{knit}()}; instead it must be placed in a parent document to let
#'   \code{\link{knit}()} call it indirectly.
#'
#'   The path of the child document is relative to the parent document.
#' @export
#' @examples # you can write \Sexpr{knit_child('child-doc.Rnw')} in an Rnw file 'main.Rnw' to input results from child-doc.Rnw in main.tex
#'
#' # comment out the child doc by \Sexpr{knit_child('child-doc.Rnw', eval = FALSE)}
knit_child = function(..., options = NULL, envir = knit_global()) {
  child = child_mode()
  opts_knit$set(child = TRUE) # yes, in child mode now
  on.exit(opts_knit$set(child = child)) # restore child status
  if (is.list(options)) {
    options$label = options$child = NULL  # do not need to pass the parent label on
    if (length(options)) {
      optc = opts_chunk$get(names(options), drop = FALSE); opts_chunk$set(options)
      # if user did not touch opts_chunk$set() in child, restore the chunk option
      on.exit({
        for (i in names(options)) if (identical(options[[i]], opts_chunk$get(i)))
          opts_chunk$set(optc[i])
      }, add = TRUE)
    }
  }
  res = knit(..., tangle = opts_knit$get('tangle'), envir = envir,
             encoding = opts_knit$get('encoding') %n% getOption('encoding'))
  paste(c('', res), collapse = '\n')
}

#' Exit knitting early
#'
#' Sometimes we may want to exit the knitting process early, and completely
#' ignore the rest of the document. This function provides a mechanism to
#' terminate \code{\link{knit}()}.
#' @param append a character vector to be appended to the results from
#'   \code{knit()} so far; by default, it is \verb{\end{document}} for LaTeX
#'   output, and \verb{</body></html>} for HTML output to make the output
#'   document complete; for other types of output, it is an empty string
#' @return Invisible \code{NULL}. An internal signal is set up (as a side
#'   effect) to notify \code{knit()} to quit as if it had reached the end of the
#'   document.
#' @export
#' @examples # see https://github.com/yihui/knitr-examples/blob/master/096-knit-exit.Rmd
knit_exit = function(append) {
  if (missing(append)) append = if (out_format(c('latex', 'sweave', 'listings')))
    '\\end{document}' else if (out_format('html')) '</body>\n</html>' else ''
  .knitEnv$terminate = append # use this terminate variable to notify knit()
  invisible()
}

knit_log = new_defaults()  # knitr log for errors, warnings and messages

#' Wrap evaluated results for output
#'
#' @param x output from \code{\link[evaluate]{evaluate}}
#' @param options list of options used to control output
#' @noRd
wrap = function(x, options = list(), ...) {
  UseMethod('wrap', x)
}

#' @export
wrap.list = function(x, options = list()) {
  if (length(x) == 0L) return(x)
  lapply(x, wrap, options)
}

# ignore unknown classes
#' @export
wrap.default = function(x, options) return()

#' @export
wrap.character = function(x, options) {
  if (options$results == 'hide') return()
  if (output_asis(x, options)) {
    if (!out_format('latex')) return(x)  # latex output still need a tweak
  } else x = comment_out(x, options$comment)
  knit_hooks$get('output')(x, options)
}

# if you provide a custom print function that returns a character object of
# class 'knit_asis', I'll just write it as is
#' @export
wrap.knit_asis = function(x, options, inline = FALSE) {
  if (isFALSE(attr(x, 'knit_cacheable', exact = TRUE)) &&
        (!missing(options) && options$cache > 0))
    stop("The code chunk '", options$label, "' is not cacheable; ",
         "please use the chunk option cache=FALSE on this chunk")
  m = attr(x, 'knit_meta', exact = TRUE)
  if (length(m)) {
    .knitEnv$meta = c(.knitEnv$meta, m)
  }
  x = as.character(x)
  if (!out_format('latex') || inline) return(x)
  # latex output need the \end{kframe} trick
  options$results = 'asis'
  knit_hooks$get('output')(x, options)
}

#' @export
wrap.source = function(x, options) {
  src = sub('\n$', '', x$src)
  if (!options$collapse && options$strip.white) src = strip_white(src)
  if (is_blank(src)) return()  # an empty chunk
  knit_hooks$get('source')(src, options)
}

msg_wrap = function(message, type, options) {
  # when output format is latex, do not wrap messages (let latex deal with wrapping)
  if (!length(grep('\n', message)) && !out_format(c('latex', 'listings', 'sweave')))
    message = str_wrap(message, width = getOption('width'))
  knit_log$set(setNames(
    list(c(knit_log$get(type), str_c('Chunk ', options$label, ':\n  ', message))),
    type
  ))
  knit_hooks$get(type)(comment_out(message, options$comment), options)
}

#' @export
wrap.warning = function(x, options) {
  call = if (is.null(x$call)) '' else {
    call = deparse(x$call)[1]
    if (call == 'eval(expr, envir, enclos)') '' else paste(' in', call)
  }
  msg_wrap(sprintf('Warning%s: %s', call, x$message), 'warning', options)
}

#' @export
wrap.message = function(x, options) {
  msg_wrap(paste(x$message, collapse = ''), 'message', options)
}

#' @export
wrap.error = function(x, options) {
  msg_wrap(as.character(x), 'error', options)
}

#' @export
wrap.recordedplot = function(x, options) {
  # figure number sequence for multiple plots
  fig.cur = plot_counter()
  options$fig.cur = fig.cur # put fig num in options
  name = fig_path('', options, number = fig.cur)
  if (!file_test('-d', dirname(name)))
    dir.create(dirname(name), recursive = TRUE) # automatically creates dir for plots
  # vectorize over dev, ext and dpi: save multiple versions of the plot
  file = mapply(
    save_plot, width = options$fig.width, height = options$fig.height,
    dev = options$dev, ext = options$fig.ext, dpi = options$dpi,
    MoreArgs = list(plot = x, name = name, options = options), SIMPLIFY = FALSE
  )[[1]]
  if (options$fig.show == 'hide') return('')
  knit_hooks$get('plot')(file, reduce_plot_opts(options))
}

#' A custom printing function
#'
#' The S3 generic function \code{knit_print} is the default printing function in
#' \pkg{knitr}. The chunk option \code{render} uses this function by default.
#' The main purpose of this S3 generic function is to customize printing of R
#' objects in code chunks. We can fall back to the normal printing behavior by
#' setting the chunk option \code{render = normal_print}.
#'
#' Users can write custom methods based on this generic function. For example,
#' if we want to print all data frames as tables in the output, we can define a
#' method \code{knit_print.data.frame} that turns a data frame into a table (the
#' implementation may use other R packages or functions, e.g. \pkg{xtable} or
#' \code{\link{kable}()}).
#' @param x an R object to be printed
#' @param ... additional arguments passed to the S3 method (currently ignored,
#'   except two optional arguments \code{options} and \code{inline}; see
#'   References)
#' @return The value returned from the print method should be a character vector
#'   or can be converted to a character value. You can wrap the value in
#'   \code{\link{asis_output}()} so that \pkg{knitr} writes the character value
#'   as is in the output.
#' @note It is recommended to leave a \code{...} argument in your method, to
#'   allow future changes of the \code{knit_print()} API without breaking your
#'   method.
#' @references See \code{vignette('knit_print', package = 'knitr')}.
#' @export
#' @examples library(knitr)
#' # write tables for data frames
#' knit_print.data.frame = function(x, ...) {
#'   res = paste(c('', '', kable(x, output = FALSE)), collapse = '\n')
#'   asis_output(res)
#' }
#' # after you defined the above method, data frames will be printed as tables in knitr,
#' # which is different with the default print() behavior
knit_print = function(x, ...) {
  UseMethod('knit_print', x)
}

#" the default print method is just print()/show()
#' @export
knit_print.default = function(x, ..., inline = FALSE) {
  if (inline) x else normal_print(x)
}

#' @export
knit_print.knit_asis = function(x, ...) x

#' @rdname knit_print
#' @export
normal_print = default_handlers$value
formals(normal_print) = alist(x = , ... = )

#' Mark an R object with a special class
#'
#' This is a convenience function that assigns the input object a class named
#' \code{knit_asis}, so that \pkg{knitr} will treat it as is (the effect is the
#' same as the chunk option \code{results = 'asis'}) when it is written to the
#' output.
#'
#' This function is normally used in a custom S3 method based on the printing
#' function \code{\link{knit_print}()}.
#'
#' For the \code{cacheable} argument, you need to be careful when printing the
#' object involves non-trivial side effects, in which case it is strongly
#' recommended to use \code{cacheable = FALSE} to instruct \pkg{knitr} that this
#' object should not be cached using the chunk option \code{cache = TRUE},
#' otherwise the side effects will be lost the next time the chunk is knitted.
#' For example, printing a \pkg{shiny} input element in an R Markdown document
#' may involve registering metadata about some JavaScript libraries or
#' stylesheets, and the metadata may be lost if we cache the code chunk, because
#' the code evaluation will be skipped the next time.
#' @param x an R object (typically a character string, or can be converted to a
#'   character string via \code{\link{as.character}()})
#' @param meta additional metadata of the object to be printed (the metadata
#'   will be collected when the object is printed, and accessible via
#'   \code{knit_meta()})
#' @param cacheable a logical value indicating if this object is cacheable
#' @export
#' @examples  # see ?knit_print
asis_output = function(x, meta = NULL, cacheable = length(meta) == 0) {
  structure(x, class = 'knit_asis', knit_meta = meta, knit_cacheable = cacheable)
}

#' Metadata about objects to be printed
#'
#' As an object is printed, \pkg{knitr} will collect metadata about it (if
#' available). After knitting is done, all the metadata is accessible via this
#' function.
#' @param class optionally return only metadata entries that inherit from the
#'   specified class; the default, \code{NULL}, returns all entries.
#' @param clean whether to clean the collected metadata; by default, the
#'   metadata stored in \pkg{knitr} is cleaned up once retrieved, because we may
#'   not want the metadata to be passed to the next \code{knit()} call; to be
#'   defensive (i.e. not to have carryover metadata), you can call
#'   \code{knit_meta()} before \code{knit()}
#' @export
knit_meta = function(class = NULL, clean = TRUE) {
  matches = if (is.null(class)) {
    # if no class was specified, match the whole list
    seq_along(.knitEnv$meta)
  } else if (length(.knitEnv$meta)) {
    # if a class was specified, match the items belonging to the class
    which(sapply(.knitEnv$meta, inherits, what = class))
  }
  if (length(matches) < 1) return(list())
  if (clean) on.exit(.knitEnv$meta[matches] <- NULL, add = TRUE)
  .knitEnv$meta[matches]
}
