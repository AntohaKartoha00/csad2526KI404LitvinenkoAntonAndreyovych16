#include "C:\Users\User\Desktop\csad2526KI404LitvinenkoAntonAndreyovych16\math_operations.h"
#include <gtest/gtest.h>

// Тест для додавання двох позитивних чисел
TEST(AdditionTests, PositiveNumbers) {
    EXPECT_EQ(add(3, 5), 8);
    EXPECT_EQ(add(10, 20), 30);
}

// Тест для додавання двох від’ємних чисел
TEST(AdditionTests, NegativeNumbers) {
    EXPECT_EQ(add(-3, -5), -8);
    EXPECT_EQ(add(-10, -20), -30);
}

// Тест для додавання нуля
TEST(AdditionTests, AddingZero) {
    EXPECT_EQ(add(0, 5), 5);
    EXPECT_EQ(add(7, 0), 7);
    EXPECT_EQ(add(0, 0), 0);
}

// Тест для додавання великого числа
TEST(AdditionTests, LargeNumbers) {
    EXPECT_EQ(add(1000000, 2000000), 3000000);
    EXPECT_EQ(add(-1000000, 2000000), 1000000);
}

// Основна функція для запуску тестів
int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}