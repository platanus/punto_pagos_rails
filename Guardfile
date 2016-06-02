rspec_options = {
  results_file: File.expand_path("tmp/guard_rspec_results.txt"),
  cmd: "zeus rspec",
  all_after_pass: true,
  failed_mode: :focus
}

guard :rspec, rspec_options do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/dummy/spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  # Rails example
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/dummy/spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/dummy/spec/support/(.+)\.rb$})       { "spec" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }
  watch('spec/rails_helper.rb')                       { "spec" }
end
