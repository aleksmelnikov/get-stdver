[English](README.md) | [Russian](README-ru.md)

### Назначение скрипта:
Данный скрипт предназначен для автоматизации процесса поиска версий стандартов по умолчанию C и С++ в исходных файлах проекта GCC (GNU Compiler Collection) по релизным тегам.

### Использование скрипта:
```
cd /tmp
git clone git://gcc.gnu.org/git/gcc.git
git clone https://git@git.sourcecraft.dev/dbvmcom/get-stdver.git
(or git clone https://github.com/aleksmelnikov/get-stdver.git)
/tmp/get-stdver/get_stdver_gcc.sh /tmp/gcc
```

### Дополнительная информация:
**cpp_create_reader** - это ключевая внутренняя функция, которая инициализирует препроцессор. Один из ее аргументов - это начальный идентификатор стандарта языка.
В последующих версиях GCC дополнительно к этой установке идентификатор стандарта языка стали задавать через 'enum cxx_dialect cxx_dialect = cxx98;'
В последующих версиях GCC сделали 'enum cxx_dialect cxx_dialect = cxx_unset;' и стали задавать стандарт языка через непосредственный вызов функций вида 'set_std_*'.

### Пример данных на выходе скрипта:
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
Здесь:
строка  1: Анализируемый текущий тег (15.2.0)
строка  3: Задаются начальные идентификаторы стандартов: для С - CLK_GNUC89, для С++ - CLK_GNUCXX.
строка  8: Установка конечного стандарта для С   - gnu23.
строка 13: Установка конечного стандарта для С++ - c++17.
```

### Лицензия
GNU AGPLv3

