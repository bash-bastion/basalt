# shellcheck shell=bash

load './util/init.sh'

@test "Calling 'basalt.package-load' works" {
	skip

	test_util.init_lib 'project-echo' 'subpkg' \
		'default' \
		'default'
	( cd subpkg && basalt install )


	test_util.init_app 'myapp' 'somepkg' \
		"dependencies = ['file://../subpkg']" \
		'default'
	cd somepkg
	basalt install

	run ./pkg/bin/myapp
	assert_success
	assert_line 'myapp basalt app'

	test_util.run_commands "project-echo.fn"
}
