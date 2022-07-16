local nk = require("nakama")

local HTTPS_PREFIX = "https://"
local SENDINBLUE_URL = "https://api.sendinblue.com/v3/smtp/email"

local function verify_email(context, payload)

	local http_key = "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"

	local url = string.format(SENDINBLUE_URL, HTTPS_PREFIX)

	local json_payload = nk.json_decode(payload)
	local email = json_payload.email

	local query = [[SELECT id FROM users WHERE email = $1 LIMIT 1]]
	local query_result = nk.sql_query(query, { email })

	if next(query_result) == nil then
		return nk.json_encode({
			["success"] = false,
			["error"] = "Email does not exist!"
		})
	end

	local user_id = query_result[1].id

	

	local content = {
          "to":[  
		{  
	       		"email": email
		}
	        ],
        	"templateId": 1,
		"params": { 
 			"OTP": math.random(000000, 999999),
		}
	}
	local method = "POST"
	local headers = {
		["Content-Type"] = "application/x-www-form-urlencoded",
    ["api-key"] = "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",
	}

	local success, code, headers, body = pcall(nk.http_request, url, method, headers, content)
	if (not success) then
		nk.logger_error(string.format("Failed %q", code))
		return nk.json_encode({
			["success"] = false,
			["error"] = code
		})
	elseif (code >= 400) then
		nk.logger_error(string.format("Failed %q %q", code, body))
		return nk.json_encode({
			["success"] = false,
			["error"] = code,
			["response"] = body
		})
	else
		nk.logger_info(string.format("Success %q %q", code, body))
		return nk.json_encode({
			["success"] = true,
			["response"] = nk.json_decode(body),
      ["otp"] = content["params"]["OTP"]
		})
	end
end
nk.register_rpc(verify_email, "verify_email")