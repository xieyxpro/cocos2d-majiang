
--------类型检查工具类----------
type_check = {}

--类型检查，空类型
function type_check:assert_not_nil( varname )
	assert(nil ~= type(varname))
end

--类型检查，表格类型
function type_check:assert_table( varname )
	assert("table" == type(varname))
end

--类型检查，整型类型
function type_check:assert_number( varname )
	assert("number" == type(varname))
end

--类型检查，条件真
function type_check:assert_true( varname )
	assert(true == varname)
end