use inc::Module::Install;
name 'Net-Twitter-OAuth';
all_from 'lib/Net/Twitter/OAuth.pm';

requires 'Net::Twitter';
requires 'Net::OAuth::Simple';

build_requires 'Test::More';
use_test_base;
auto_include_deps;
author_tests('xt');
auto_set_repository;
WriteAll;
