class Multiplexer < BasicObject
  def initialize(*objs)
    @objs = objs
  end

  def method_missing(*args, &blk)
    @objs.map { |o| o.send(*args, &blk) }.first
  end
end
