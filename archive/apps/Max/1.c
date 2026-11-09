#include <stdio.h>

int main() {
    int arr[20] = {1,4,7,2,8,11,3,15,6,9,12,14,10,13,5,0,2,3,4,8};
    
    int max_index, max;
    max_index = 0;
    max = arr[0];

    for (int i = 1; i < 20; i++) {
        if (arr[i] > max) {
            max = arr[i];
            max_index = i;
        }
    }

    printf("The maximum value is %d at index %d\n", max, max_index);

}