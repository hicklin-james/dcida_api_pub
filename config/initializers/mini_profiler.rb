# config/initializers/mini_profiler.rb

# Rails.application.routes.append do
#   mini_profiler = Rack::MiniProfiler.new(Rails.application)
#   get '/profiler' => ->(env) {
#     [200, {}, [<<-BODY.strip_heredoc]]
#     <html>
#     <head>
#     </head>
#     <body>
#     #{mini_profiler.get_profile_script(env)}
#     </body>
#     </html>
#     BODY
#   }
# end