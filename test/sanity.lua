local ffi = require "ffi"
local lunit = require "lunitx"
local capnp = require "capnp"
local util = require "util"

local handwritten = require "handwritten_capnp"

local T1 = handwritten.T1

if _VERSION >= 'Lua 5.2' then
    _ENV = lunit.module('simple','seeall')
else
    module( "simple", package.seeall, lunit.testcase )
end

local to_hex_string = function(seg)
    local t = {}
    for i = 1, seg.pos do
        table.insert(t, bit.tohex(seg.data[i - 1], 2))
    end
    return table.concat(t, " ")
end

local assert_hex = function (expected, actual)
    assert_equal(expected, to_hex_string(actual))
end

local function assert_hex_string(expected, actual)
    local t = {}
    for i = 1, #actual do
        table.insert(t, bit.tohex(string.byte(actual, i), 2))
    end
    assert_equal(expected, table.concat(t, " "))
end

function test_write_plain_val()
    local seg = { len = 32, pos = 0 }
    seg.data = ffi.new("char[?]", 32) -- 32 bytes

    -- write_val(buf, val, size, off)
    capnp.write_val(seg.data, true, 1, 0)
    capnp.write_val(seg.data, 8, 8, 1)
    capnp.write_val(seg.data, 65535, 16, 1)
    capnp.write_val(seg.data, 1048576, 32, 1)
    capnp.write_val(seg.data, 4294967296, 64, 1)
    capnp.write_val(seg.data, 3.14, 32, 4)
    capnp.write_val(seg.data, 1.41421, 32, 5)
    capnp.write_val(seg.data, 3.14159265358979, 64, 3)

    seg.pos = seg.pos + 32
    assert_hex("01 08 ff ff 00 00 10 00 00 00 00 00 01 00 00 00 c3 f5 48 40 d5 04 b5 3f 11 2d 44 54 fb 21 09 40", seg)
end

function test_write_plain_val1()
    local seg = { len = 32, pos = 0 }
    seg.data = ffi.new("char[?]", 32) -- 32 bytes

    -- write_val(buf, val, size, off)
    capnp.write_val(seg.data, -1, 8, 0)
    --[[
    capnp.write_val(seg.data, 8, 8, 1)
    capnp.write_val(seg.data, 65535, 16, 1)
    capnp.write_val(seg.data, 1048576, 32, 1)
    capnp.write_val(seg.data, 4294967296, 64, 1)
    capnp.write_val(seg.data, 3.14, 32, 4)
    capnp.write_val(seg.data, 1.41421, 32, 5)
    capnp.write_val(seg.data, 3.14159265358979, 64, 3)
    ]]

    seg.pos = seg.pos + 32
    assert_hex("ff 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00", seg)
end

--[[
function test_write_structp()
    local seg = capnp.new_segment() -- 32 bytes

    capnp.write_structp(seg.data, T1, 0)

    seg.pos = seg.pos + 8
    assert_hex("00 00 00 00 02 00 03 00", seg)
end

function test_write_structp1()
    local seg = capnp.new_segment()

    capnp.write_structp(seg.data + 8, T1, 2)
    seg.pos = seg.pos + 16

    assert_hex("00 00 00 00 00 00 00 00 08 00 00 00 02 00 03 00", seg)
end

function test_write_listp()
    local seg = capnp.new_segment(8)

    -- write_listp = function (buf, size, num, data_off)
    capnp.write_listp(seg.data, 2, 1, 0)

    seg.pos = seg.pos + 8
    assert_hex("01 00 00 00 0a 00 00 00", seg)
end
]]

function test_underscore_naming()
    assert_equal("request_uri", util.lower_underscore_naming("requestURI"))
    assert_equal("REQUEST_URI", util.upper_underscore_naming("requestURI"))
    assert_equal("REQUEST", util.upper_underscore_naming("request"))
    assert_equal("TEST_RES", util.upper_underscore_naming("testRes"))
end
