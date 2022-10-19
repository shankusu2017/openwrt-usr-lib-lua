module("luci.controller.myapp.new_tab", package.seeall) --new_tab要和文件名一致

function index()
	entry({"admin", "new_tab"}, firstchild(), "New tab", 60).dependent=false -- 添加一个顶层导航
	entry({"admin", "new_tab", "tab_from_cbi"}, cbi("myapp-mymodule/cbi_tab"), "CBI Tab", 1) -- 在New tab下添加一个子选项CBI Tab
	entry({"admin", "new_tab", "tab_from_view"}, template("myapp-mymodule/view_tab"), "View Tab", 2) -- 在New tab下添加一个子选项vIEW Tab
end
