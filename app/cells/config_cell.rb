class ConfigCell < FissionCell

  def show(args)
    @arguments = args
  end

  def edit(args)
    @arguments = args
    @config = arguments[:config]
    @form = arguments[:form]
    @value = arguments[:value]
    @name = arguments[:name]
  end

end
