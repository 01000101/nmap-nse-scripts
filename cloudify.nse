---
-- @usage
-- nmap --script cloudify <target>
-- @output
-- Host script results:
-- | cloudify:
-- |   version: 3.4.0
-- |_  build: 85

local shortport = require "shortport"
local http = require "http"
local stdnse = require "stdnse"
local json = require "json"

-- The Head --
author = "Joshua Cornutt"
categories = {"discovery", "safe"}
license = "MIT"
description = [[
  Attempts to identify a Cloudify REST API.

  This script works by attempting to GET /version and expects a
  JSON-formatted response with specific fields required. As a
  safety measure, it also attempts to GET /blueprints which
  should report as a valid endpoint. The version and build
  of the Cloudify Manager are reported as outputs.
]]

-- The Rule --
portrule = shortport.http

-- The Action --
action = function(host, port)
  local json_isvalid, res, version
  -- Get the /version
  res = http.get(host, port, "/version")
  -- Check HTTP status
  stdnse.debug("GET /version status: %s", res.status)
  if( not(res.status == 200) ) then
    stdnse.debug("Bad HTTP status returned; expected 200")
    return
  end
  -- Convert response to JSON object
  json_isvalid, version = json.parse(res.body)
  if not(json_isvalid) then
    stdnse.debug("Error converting to JSON object")
    return
  end
  if not(version.version) then
    stdnse.debug("Missing version key")
    return
  end
  -- Test if the /blueprints path exists
  if not(http.get(host, port, "/blueprints").status == 200) then
    stdnse.debug("Missing /blueprints endpoint")
    return
  end
  -- Format for output
  local output_tab = stdnse.output_table()
  output_tab.version = version.version
  output_tab.build = version.build
  return output_tab
end
