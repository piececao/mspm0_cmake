#include "ti_msp_dl_config.h"

int main(void)
{
    SYSCFG_DL_init();

    while (1) {
        DL_GPIO_setPins(LEDs_PORT, LEDs_Green_PIN);
        delay_cycles(32000000);
        DL_GPIO_clearPins(LEDs_PORT, LEDs_Green_PIN);
        delay_cycles(32000000);
    }
}