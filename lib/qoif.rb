# frozen_string_literal: true

require_relative "qoif/version"

module Qoif
  RGB = 3
  RGBA = 4

  class Error < StandardError; end
  # Your code goes here...

  class Encoder
    def initialize(width, height, mode: Qoif::RGB)
      @width = width
      @height = height
      @channels = mode
    end

    def encode(pixels, io)
      @cache = []
      previous_pixel = 0x000000FF
      write_to_cache previous_pixel

      io.write [*"qoif".unpack("C4"), @width, @height, @channels, 0].pack("C4L>2CC")

      run = 0

      pixels.each_with_index do |pixel, index|
        # set alpha channel to 0xFF
        pixel |= 0xFF if @channels == 3

        if run > 0 && (pixel != previous_pixel || run == 62 || index == pixels.length - 1)
          io.write (0b11000000 | (run - 1)).chr
          run = 0
        end

        if pixel == previous_pixel
          run += 1
        elsif pos = find_in_cache(pixel)
          io.write pos.chr
        elsif (pixel & 0xFF) == (previous_pixel & 0xFF) &&
          (r_diff, g_diff, b_diff = pixel_difference(pixel, previous_pixel)) && 
          r_diff.between?(-2, 1) && g_diff.between?(-2, 1) && b_diff.between?(-2, 1)

          io.write (0b01000000 | ((r_diff + 2) << 4) | ((g_diff + 2) << 2) | (b_diff + 2)).chr
        elsif @channels == 3 || (pixel & 0xFF) == (previous_pixel & 0xFF)
          io.write [
            0b11111110,
            pixel >> 24,
            (pixel >> 16) & 0xFF,
            (pixel >> 8) & 0xFF,
          ].pack("C4")
        else
          io.write [
            0b11111111,
            pixel,
          ].pack("CL>")
        end

        write_to_cache(pixel)
        previous_pixel = pixel
      end

      io.write "\x00\x00\x00\x00\x00\x00\x00\x01"
      io.close
    end

    private

    def write_to_cache(pixel)
      position = pixel_hash(pixel)
      @cache[position] = pixel
    end

    def find_in_cache(pixel)
      position = pixel_hash(pixel)
      if !@cache[position].nil? && @cache[position] == pixel
        position
      else
        nil
      end
    end

    def pixel_hash(pixel)
      ((pixel >> 24) * 3 + ((pixel >> 16) & 0xFF) * 5 + ((pixel >> 8) & 0xFF) * 7 + (pixel & 0xFF) * 11) % 64
    end

    def pixel_difference(p1, p2)
      r_diff = (p1 >> 24) - (p2 >> 24)
      g_diff = (p1 >> 16 & 0xFF) - (p2 >> 16 & 0xFF)
      b_diff = (p1 >> 8 & 0xFF) - (p2 >> 8 & 0xFF)

      [r_diff, g_diff, b_diff]
    end
  end
end
