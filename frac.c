#include <stdio.h>
#include <string.h>
#include <math.h>

void int_to_binary(char *res, int dec)
{
    int i = 0;
    while (dec > 0)
    {
        res[i] = (dec % 2) + '0';
        dec /= 2;
        i++;
    }

    for (int j = 0; j <= i / 2; j++)
    {
        char temp = res[j];
        res[j] = res[i - j - 1];
        res[i - j - 1] = temp;
    }
}

int main(void)
{
    int absolute, frac;
    printf("Number: ");
    scanf("%d%*c%d", &absolute, &frac);
    int accuracy;
    printf("Accuracy: ");
    scanf("%d", &accuracy);

    char str_absolute[60];
    int_to_binary(str_absolute, absolute);
    printf("%s.", str_absolute);

    int fp_digits = pow(10, floor(log10(frac)) + 1);
    int temp = frac;
    for (int i = 0; i < accuracy && temp != 0; i++)
    {
        temp = (temp % fp_digits) * 2;
        if (temp >= fp_digits)
            printf("1");
        else
            printf("0");
    }

    printf("\n");

    return 0;
}
