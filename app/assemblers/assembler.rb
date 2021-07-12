class Assembler
  protected
  def sideload?(item)
    return false unless params[:sideload]

    params[:sideload].include?(item.to_s)
  end
end
