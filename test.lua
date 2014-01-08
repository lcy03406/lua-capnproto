--local test_capnp = require "handwritten_capnp"
package.path = "lua/?.lua;proto/?.lua;" .. package.path

local data_generator = require "data_generator"
local test_capnp = require "example_capnp"
local capnp = require "capnp"
local cjson = require "cjson"
local util = require "util"

local format = string.format

local data = {
    i0 = 32,
    i1 = 16,
    i2 = 127,
    b0 = true,
    b1 = true,
    i3 = 65536,
    e0 = "enum3",
    s0 = {
        f0 = 3.14,
        f1 = 3.14159265358979,
    },
    l0 = { 28, 29 },
    t0 = "hello",
    e1 = "enum7",
}

local file = arg[1]
local f = io.open(file, "w")
f:write(test_capnp.T1.serialize(data))
f:close()


local generated_data = data_generator.gen_t1()
local f = io.open("random.data", "w")
f:write(test_capnp.T1.serialize(generated_data))
f:close()
local f = io.open("random.cjson.data", "w")
f:write(cjson.encode(generated_data))
f:close()


function table_diff(t1, t2, namespace)
    local keys = {}

    for k, v in pairs(t1) do
        keys[k] = true
    end

    for k, v in pairs(t2) do
        keys[k] = true
    end

    for k, v in pairs(keys) do
        local name = namespace .. "." .. k
        local v1 = t1[k]
        local v2 = t2[k]

        local t1 = type(v1)
        local t2 = type(v2)

        if t1 ~= t2 then
            print(format("%s: different type: %s %s", name,
                    t1, t2))
        elseif t1 == "table" then
            table_diff(v1, v2, namespace .. "." .. k)
        elseif v1 ~= v2 then
            print(format("%s: different value: %s %s", name,
                    tostring(v1), tostring(v2)))
        end
    end
end

function write_file(name, content)
    local f = assert(io.open(name, "w"))
    f:write(content)
    f:close()
end

function random_test()
    local generated_data = data_generator.gen_t1()

    local bin = test_capnp.T1.serialize(generated_data)

    local outfile = "/tmp/T1.txt"
    os.execute("rm " .. outfile)
    local fh = assert(io.popen("capnp decode proto/example.capnp T1 > "
            .. outfile, "w"))
    fh:write(bin)
    fh:close()

    write_file("T1.capnp.bin", bin)

    local decoded = util.parse_capnp_decode(outfile, "debug.txt")

    print(cjson.encode(generated_data))
    print(cjson.encode(decoded))

    table_diff(generated_data, decoded, "")
end

random_test()
print("Done")
