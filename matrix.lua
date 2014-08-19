local function matrix(m)
	local m = m or {
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		0, 0, 0, 1,
	}
	local len = #m
	local fn = {}
	local sin = math.sin
	local cos = math.cos

	fn.identity = function()
		for i=1,16 do
			if i==1 or i==6 or i==11 or i==16 then
				m[i] = 1
			else
				m[i] = 0
			end
		end
	end

	fn.tostring = function()
		local out = {}
		assert(type(m)=="table" and (#m >= 4) and (#m <= 16), 'Invalid matrix')
		for i=1,#m do
			table.insert(out, ("%03f "):format(tonumber(m[i])))
			if i%4 == 0 then
				table.insert(out, "\n")
			end
		end
		return table.concat(out)
	end

	fn.dup = function()
		return matrix(m)
	end
	fn.rotate = function(x,y,z,angle)
		local s = math.sin(angle)
		local c = math.cos(angle)
		local c1 = 1 - c
		local xy,xz,yz = x*y, x*z, y*z
		local xx,yy,zz = x*x, y*y, z*z
		local xs,ys,zs = x*s, y*s, z*s

		return matrix {
			c + xx*c1, 		xy*c1 - zs, 	xz*c1 + ys, 0,
			xy*c1 + zs, 	c+ yy*c1, 		yz*c1 - xs , 0,
			xz*c1 - ys, 	yz*c1 + xs, 	c + zz*c1, 0,
			0, 0, 0, 1,
		}
	end

	fn.rotateX = function(angle)
		return matrix {
			1, 0, 0, 0,
			0, cos(angle), -sin(angle), 0,
			0, sin(angle), cos(angle), 0,
			0, 0, 0, 1,
		}
	end
	fn.rotateY = function(angle)
		return matrix {
			cos(angle), 0, sin(angle), 0,
			0, 1, 0, 0,
			-sin(angle), 0, cos(angle), 0,
			0, 0, 0, 1,
		}
	end
	fn.rotateZ = function(angle)
		return matrix {
			cos(angle), -sin(angle), 0, 0,
			sin(angle), cos(angle), 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1,
		}
	end

	fn.translateX = function(amount)
		return matrix {
			1, 0, 0, amount,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1,
		}
	end
	fn.translateY = function(amount)
		return matrix {
			1, 0, 0, 0,
			0, 1, 0, amount,
			0, 0, 1, 0,
			0, 0, 0, 1,
		}
	end
	fn.translateZ = function(amount)
		return matrix {
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, amount,
			0, 0, 0, 1,
		}
	end
	fn.translate = function(x,y,z)
		assert(type(x)=="number" and type(y)=="number" and type(z)=="number")
		return matrix {
			1, 0, 0, x,
			0, 1, 0, y,
			0, 0, 1, z,
			0, 0, 0, 1,
		}
	end

	fn.scaleX = function(amount)
		return matrix {
			amount, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1,
		}
	end
	fn.scaleY = function(amount)
		return matrix {
			1, 0, 0, 0,
			0, amount, 0, 0,
			0, 0, 1, 0,
			0, 0, 0, 1,
		}
	end
	fn.scaleZ = function(amount)
		return matrix {
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, amount, 0,
			0, 0, 0, 1,
		}
	end
	fn.scale = function(x,y,z)
		assert(type(x)=="number" and type(y)=="number" and type(z)=="number")
		return matrix {
			x, 0, 0, 0,
			0, y, 0, 0,
			0, 0, z, 0,
			0, 0, 0, 1,
		}
	end
	fn.invScale = function()
		local out = {}
		for i=0,3 do
    		for j=0,3 do
   				local bi = i + (j*4) +1
   				if i==j then
    				out[bi] = 1/m[bi]
   				else
    				out[bi] = m[bi]
    			end
    		end
		end    			

		return matrix(out)
	end
	fn.invTranslate = function()
		local out = {}
		for i=0,3 do
    		for j=0,3 do
   				local bi = i + (j*4) +1
   				if i==3 then
    				out[bi] = -m[bi]
   				else
    				out[bi] = m[bi]
    			end
    		end
		end    			

		return matrix(out)
	end
	fn.transpose = function()
		local out = {}
		for i=0,3 do
			for j=0,3 do
				local I0 = j + (i*4) + 1
				local I1 = i + (j*4) + 1
				out[I1] = m[I0]
			end
		end
		return matrix(out)
	end
	fn.skew = function(x, y, z)
		local x,y,z = x or 0, y or 0, z or 0
		return matrix {
			1, 0, 0, 0,
			0, 1, 0, 0,
			0, 0, 1, 0,
			x, y, z, 1,
		}
	end
	fn.projection = function(fov, aspect, znear, zfar)
		local xymax = znear * math.tan(fov * math.pi/360)
		local ymin = -xymax
		local xmin = -xymax

		local width = xymax - xmin
		local height = xymax - ymin

		local depth = zfar - znear
		local q = -(zfar + znear) / depth
		local qn = -2 * (zfar * znear) / depth

		local w = 2 * znear / width
		w = w / aspect
		local h = 2 * znear / height

		return matrix {
			w, 0, 0, 0,
			0, h, 0, 0,
			0, 0, q, -1,
			0, 0, qn, 0,
		}
	end

	local mt = {
		__index = function(t, i)
			if type(i)=="string" then
				local f = fn[i]
				if type(f)=='function' then
					return f
				end
			else
				return rawget(m, i)
			end
		end,
		__add = function(a, b)
			local out = {}
			assert(#a == #b)
			for i=1,#a do
				out[i] = a[i] + b[i]
			end
			return matrix(out)
		end,
		__sub = function(a, b)
			local out = {}
			for i=1,#a do
				out[i] = a[i] - b[i]
			end
			return matrix(out)
		end,
		__unm = function(a)
			local out = {}
			for i=1,#a do
				out[i] = -a[i]
			end
			return matrix(out)
		end,
		__len = function(a)
			return len
		end,
		__mul = function(a, b)
			local out = {}
			if type(a)=="table" and type(b)=="table" then
				if #a == #b then
        			for i=0,3 do
        				for j=0,3 do
        					local sum = 0
        					for k=0,3 do
        						local ai = k + (j*4) + 1
        						local bi = i + (k*4) + 1
        						sum = sum + a[ai] * b[bi]
        					end		
        					out[i + (j*4) +1 ] = sum
        				end
        			end
    			else
    				-- vector x matrix 1x4 X 4x4 = 1x4
    				if #a<#b then
            			for i=0,3 do
           					local sum = 0
       						local ai = i + 1
            				for j=0,3 do
           						local bi = i + (j*4) + 1
           						sum = sum + a[j+1] * b[bi]
            				end
           					out[ai] = sum
            			end
    				-- matrix x vector	4x4 X 4x1 = 4x1
    				else
            			for i=0,3 do
           					local sum = 0
       						local bi = i + 1
            				for j=0,3 do
           						local ai = j + (i*4) + 1
           						sum = sum + a[ai] * b[j+1]
            				end
           					out[bi] = sum
            			end
           			end
    			end
    		elseif type(a)=="table" and type(b)=="number" then
    			for i=0,3 do
    				for j=0,3 do
   						local ai = i + (j*4) +1
    					out[bi] = a[bi]*b
    				end
				end    			
    		elseif type(a)=="number" and type(b)=="table" then
    			for i=0,3 do
    				for j=0,3 do
   						local bi = i + (j*4) +1
    					out[bi] = a*b[bi]
    				end
				end    			
			end
			return matrix(out)
		end,
	}

	setmetatable(m, mt)
	return m
end

math.matrix = matrix