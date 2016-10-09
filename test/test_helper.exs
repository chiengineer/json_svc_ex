ExUnit.configure formatters: [JUnitFormatter, ExUnit.CLIFormatter]
ExUnit.configure(exclude: [skip: true])
ExUnit.start()
