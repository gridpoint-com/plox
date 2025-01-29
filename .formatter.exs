# Used by "mix format"
[
  plugins: [Styler, Phoenix.LiveView.HTMLFormatter],
  import_deps: [:phoenix],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  migrate_eex_to_curly_interpolation: false
]
