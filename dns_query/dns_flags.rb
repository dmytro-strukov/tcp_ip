module DNSFlags
  FLAGS_TOTAL_SIZE = 16
  FLAGS_SIZE = {
    QR: 1,
    OP_CODE: 4,
    AA: 1,
    TC: 1,
    RD: 1,
    RA: 1,
    Z: 3,
    R_CODE: 4
  }

  DEFAULT_FLAGS = [
    [:QR, 0],
    [:OP_CODE, 0],
    [:AA, 0],
    [:TC, 0],
    [:RD, 1],
    [:RA, 0],
    [:Z, 0],
    [:R_CODE, 0] 
  ]

  def make(flags = DEFAULT_FLAGS)
    output = 0
    available_bits = FLAGS_TOTAL_SIZE

    flags.each_with_index do |flag, index|
      name, value = flag
      available_bits -= FLAGS_SIZE.fetch(name)

      if flags[index] != flags.last
        output |= value << available_bits
      else
        output |= value
      end
    end

    output
  end

  module_function :make
end 