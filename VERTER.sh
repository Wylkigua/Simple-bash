#!/bin/bash

# Компиляция cat и grep
echo "Compiling s21_cat and s21_grep..."
cd src/cat && make
cd ../grep && make
cd ../..

echo "Run tests:"
echo
echo
echo "21 School"
echo
echo
echo "VERTER is watching your code...¯\\_(ツ)_/¯"
echo
echo "-------------------------------------------------------------------------------"
echo
echo "Style test"
echo
echo "Style test output:"

# Проверка стиля кода с использованием clang-format
if clang-format -style=google -n src/cat/*.c src/cat/*.h src/grep/*.c src/grep/*.h; then
    echo " Style test: OK"
    echo "1"
    echo "Style test result: 1"
else
    echo " Style test: FAIL"
    echo "0"
    echo "Style test result: 0"
fi

echo "-------------------------------------------------------------------------------"

# Функция для создания тестовых файлов
create_test_files() {
    mkdir -p test_files && cd test_files || exit

    # Файлы для тестов cat
    echo -e "Line 1\nLine 2\nLine 3" > 1.file
    echo -e "\n\n\nEnd of file\n" > 3.file
    echo -e "Line 1\nLine 2\nLine 3" > 4.file
    echo -e "\nLine 1\nLine 2\n" > 5.file
    echo -e "\n\n\nLine\n\n" > 6.file
    echo -e "\tTab\tSeparated\tText" > 8.file
    echo -e "Single line file" > 9.file
    echo -e "reflect\nreflection\nreflex" > 10_1.file
    echo -e "mirror\nreflect\nshade" > 10_2.file
    echo -e "TrulyAlya\ntrulyalya\nTRULYALYA" > 11.file
    echo -e "space\nspirit\nsoul" > 12.file
    echo -e "test\nspace\ncase" > 13.file
    echo "space" > 14_1.file
    echo "case" > 14_2.file
    echo "test" > 14_3.file
    echo -e "line1\nspace\nline3" > 15.file
    echo -e "123\n456\n789" > 16.file
    echo "reflect" > 17_1.file
    echo "mirror" > 17_2.file
    echo "pattern" > 19_1.file
    echo -e "pattern\ntest\ncase" > 19_2.file
    echo -e "TrulyAlya\ntrulyalya" > 20.file
    echo -e "space\ntest\ncase" > 21.file
    echo -e "space\nspirit\nsoul" > 22.file
    echo "space" > 23_1.file
    echo "test" > 23_2.file
    echo "case" > 23_3.file
    echo "reflect" > 24_1.file
    echo "mirror" > 24_2.file
    echo "pattern" > 25_1.file
    echo -e "pattern\ntest\ncase" > 25_2.file
    echo -e "pattern\npattern test\npattern123" > grep_basic.txt

    cd ..
}

# Функция для тестирования
run_test() {
    local utility=$1
    local test_num=$2
    local command="$3"

    echo
    echo "Test number: $test_num, name: s21_$utility"
    echo
    echo "Test output:"

    # Функциональное тестирование
    if [ "$utility" = "cat" ]; then
        if [ "$test_num" = "7" ]; then
            # Для теста с несуществующим файлом ожидаем код возврата 1
            if ! ./src/cat/s21_cat $command 2>/dev/null; then
                echo "Functional test output: True"
                local functional_result="OK"
                local functional_test=1
            else
                echo "Functional test output: False"
                local functional_result="FAIL"
                local functional_test=0
            fi
        else
            if diff <(./src/cat/s21_cat $command 2>/dev/null) <(cat $command 2>/dev/null) >/dev/null 2>&1; then
                echo "Functional test output: True"
                local functional_result="OK"
                local functional_test=1
            else
                echo "Functional test output: False"
                local functional_result="FAIL"
                local functional_test=0
            fi
        fi
    else
        if diff <(./src/grep/s21_grep $command 2>/dev/null) <(grep $command 2>/dev/null) >/dev/null 2>&1; then
            echo "Functional test output: True"
            local functional_result="OK"
            local functional_test=1
        else
            echo "Functional test output: False"
            local functional_result="FAIL"
            local functional_test=0
        fi
    fi

    # Тест на утечки памяти
    valgrind --tool=memcheck --leak-check=yes --track-origins=yes ./src/$utility/s21_$utility $command > /dev/null 2>valgrind.log

    if grep -q "ERROR SUMMARY: 0 errors" valgrind.log; then
        local memory_result="OK"
        local memory_test=1
        echo "Memory test output:"
        cat valgrind.log | grep -A5 'HEAP SUMMARY'
    else
        local memory_result="FAIL"
        local memory_test=0
        echo "Memory test output:"
        cat valgrind.log | grep -A5 'HEAP SUMMARY'
    fi

    rm -f valgrind.log

    echo
    echo "Result for test with number $test_num: $functional_result"
    echo
    echo "Memory test: $memory_result"
    echo "$memory_test"
    echo "Test result: $((functional_test * memory_test))"
}

# Создание тестовых файлов
create_test_files

# Тестирование cat
echo "Testing s21_cat"
run_test "cat" 0 "-b test_files/1.file"
run_test "cat" 1 "-e test_files/3.file"
run_test "cat" 2 "-n test_files/4.file"
run_test "cat" 3 "test_files/5.file -n"
run_test "cat" 4 "-s test_files/6.file"
run_test "cat" 5 "-t test_files/8.file"
run_test "cat" 6 "test_files/9.file"
run_test "cat" 7 "nonexistent.txt"
run_test "cat" 8 "-z test_files/basic.txt"

# Тестирование grep
echo "Testing s21_grep"
run_test "grep" 10 "reflect test_files/10_1.file test_files/10_2.file"
run_test "grep" 11 "-i trulyalya test_files/11.file"
run_test "grep" 12 "-v s test_files/12.file"
run_test "grep" 13 "-c s test_files/13.file"
run_test "grep" 14 "-l s test_files/14_1.file test_files/14_2.file test_files/14_3.file"
run_test "grep" 15 "-n s test_files/15.file"
run_test "grep" 16 "-o 123 test_files/16.file"
run_test "grep" 17 "-h reflect test_files/17_1.file test_files/17_2.file"
run_test "grep" 18 "-s 123123 grep"
run_test "grep" 19 "-f test_files/19_1.file test_files/19_2.file"
run_test "grep" 20 "-in trulyalya test_files/20.file"
run_test "grep" 21 "-cv s test_files/21.file"
run_test "grep" 22 "-iv s test_files/22.file"
run_test "grep" 23 "-lv s test_files/23_1.file test_files/23_2.file test_files/23_3.file"
run_test "grep" 24 "-ho reflect test_files/24_1.file test_files/24_2.file"
run_test "grep" 25 "-nf test_files/25_1.file test_files/25_2.file"

# Очистка
rm -rf test_files/
#rm -f valgrind.log

# Очистка скомпилированных файлов
echo "Cleaning up compiled files..."
cd src/cat && make clean
cd ../grep && make clean
cd ../..

echo
echo "All tests completed."
