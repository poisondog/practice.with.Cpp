# A sample Makefile for building Google Test and using it in user
# tests.  Please tweak it to suit your environment and project.  You
# may want to move it to your project's root directory.
#
# SYNOPSIS:
#
#   make [all]  - makes everything.
#   make TARGET - makes the given target.
#   make clean  - removes all files generated by make.

# Please tweak the following variable definitions as needed by your
# project, except GTEST_HEADERS, which you can use in your own targets
# but shouldn't modify.

# Points to the root of Google Test, relative to where this file is.
# Remember to tweak this if you move this file.
GTEST_DIR = ../../../usr/gtest

# Where to find all user code.
DIR_SRC = src

# Where to save main source file.
DIR_SRC_MAIN = $(DIR_SRC)/main

# Where to save test source file.
DIR_SRC_TEST = $(DIR_SRC)/test

# Where to save generate file.
DIR_TARGET = target

# Where to save object file.
DIR_OBJECT_MAIN = $(DIR_TARGET)/main

# Where to save test file object
DIR_OBJECT_TEST = $(DIR_TARGET)/test

# Flags passed to the preprocessor.
# Set Google Test's header directory as a system directory, such that
# the compiler doesn't generate warnings in Google Test headers.
CPPFLAGS += -isystem $(GTEST_DIR)/include

# Flags passed to the C++ compiler.
CXXFLAGS += -g -Wall -Wextra -pthread

# All tests produced by this Makefile.  Remember to add new tests you
# created to the list.
TESTS = sample1_unittest sample2_unittest

# All Google Test headers.  Usually you shouldn't change this
# definition.
GTEST_HEADERS = $(GTEST_DIR)/include/gtest/*.h \
                $(GTEST_DIR)/include/gtest/internal/*.h

# House-keeping build targets.

all : $(TESTS)

clean :
	rm -f $(TESTS) gtest.a gtest_main.a *.o
	rm -rf $(DIR_TARGET)
	mkdir $(DIR_TARGET)
	mkdir $(DIR_OBJECT_MAIN)
	mkdir $(DIR_OBJECT_TEST)

initial :
	mkdir $(DIR_SRC)
	mkdir $(DIR_SRC_MAIN)
	mkdir $(DIR_SRC_TEST)

# Builds gtest.a and gtest_main.a.

# Usually you shouldn't tweak such internal variables, indicated by a
# trailing _.
GTEST_SRCS_ = $(GTEST_DIR)/src/*.cc $(GTEST_DIR)/src/*.h $(GTEST_HEADERS)

# For simplicity and to avoid depending on Google Test's
# implementation details, the dependencies specified below are
# conservative and not optimized.  This is fine as Google Test
# compiles fast and for ordinary users its source rarely changes.
$(DIR_OBJECT_TEST)/gtest-all.o : $(GTEST_SRCS_)
	$(CXX) $(CPPFLAGS) -I$(GTEST_DIR) $(CXXFLAGS) -c \
            $(GTEST_DIR)/src/gtest-all.cc -o $@

$(DIR_OBJECT_TEST)/gtest_main.o : $(GTEST_SRCS_)
	$(CXX) $(CPPFLAGS) -I$(GTEST_DIR) $(CXXFLAGS) -c \
            $(GTEST_DIR)/src/gtest_main.cc -o $@

gtest.a : $(DIR_OBJECT_TEST)/gtest-all.o
	$(AR) $(ARFLAGS) $@ $^

gtest_main.a : $(DIR_OBJECT_TEST)/gtest-all.o $(DIR_OBJECT_TEST)/gtest_main.o
	$(AR) $(ARFLAGS) $@ $^

# Builds a sample test.  A test should link with either gtest.a or
# gtest_main.a, depending on whether it defines its own main()
# function.

$(DIR_OBJECT_MAIN)/sample1.o : $(DIR_SRC_MAIN)/sample1.cc $(DIR_SRC_MAIN)/sample1.h $(GTEST_HEADERS)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $(DIR_SRC_MAIN)/sample1.cc -o $@
$(DIR_OBJECT_TEST)/sample1_unittest.o : $(DIR_SRC_TEST)/sample1_unittest.cc $(DIR_SRC_MAIN)/sample1.h $(GTEST_HEADERS)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $(DIR_SRC_TEST)/sample1_unittest.cc -o $@
sample1_unittest : $(DIR_OBJECT_MAIN)/sample1.o $(DIR_OBJECT_TEST)/sample1_unittest.o gtest_main.a
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -lpthread $^ -o $@

$(DIR_OBJECT_MAIN)/sample2.o : $(DIR_SRC_MAIN)/sample2.cc $(DIR_SRC_MAIN)/sample2.h $(GTEST_HEADERS)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $(DIR_SRC_MAIN)/sample2.cc -o $@
$(DIR_OBJECT_TEST)/sample2_unittest.o : $(DIR_SRC_TEST)/sample2_unittest.cc $(DIR_SRC_MAIN)/sample2.h $(GTEST_HEADERS)
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -c $(DIR_SRC_TEST)/sample2_unittest.cc -o $@
sample2_unittest : $(DIR_OBJECT_MAIN)/sample2.o $(DIR_OBJECT_TEST)/sample2_unittest.o gtest_main.a
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -lpthread $^ -o $@
