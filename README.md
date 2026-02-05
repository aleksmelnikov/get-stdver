[English](README.md) | [Russian](README-ru.md)

### Purpose of the script:
This script automates the process of finding default versions of C and C++ standards in the source files of the GCC project (GNU Compiler Collection), specifically looking through release tags.

### Usage example:
```
cd /tmp
git clone git://gcc.gnu.org/git/gcc.git
git clone https://git@git.sourcecraft.dev/dbvmcom/get-stdver.git
(or git clone https://github.com/aleksmelnikov/get-stdver.git)
/tmp/get-stdver/get_stdver_gcc.sh /tmp/gcc
```

### Additional information:
**cpp_create_reader** is a key internal function that initializes the preprocessor. One of its arguments is the initial language standard identifier.
In subsequent versions of GCC, in addition to this setting, the language standard identifier was set through 'enum cxx_dialect cxx_dialect = cxx98;'.
In later versions of GCC, they made 'enum cxx_dialect cxx_dialect = cxx_unset;' and started specifying the language standard via direct calls to functions like 'set_std_*'.

### Example output data:
```
Processing tag: releases/gcc-15.2.0
  gcc/c-family/c-opts.cc
    246:  parse_in = cpp_create_reader (c_dialect_cxx () ? CLK_GNUCXX : CLK_GNUC89,
    247-				ident_hash, line_table, ident_hash_extra);
    248-  cb = cpp_get_callbacks (parse_in);
  gcc/c-family/c-opts.cc
    264:      /* The default for C is gnu23.  */
    265-      set_std_c23 (false /* ISO */);
    266-
  gcc/c-family/c-opts.cc
    277:  /* Set C++ standard to C++17 if not specified on the command line.  */
    278-  if (c_dialect_cxx ())
    279-    set_std_cxx17 (/*ISO*/false);
Here:
line  1: The current analyzed tag (15.2.0)
line  3: Initial standard identifiers are defined: for С - CLK_GNUC89, for С++ - CLK_GNUCXX.
line  8: Final standard for C is set as gnu23.
line 13: Final standard for C++ is set as c++17.
```

### License
GNU AGPLv3
