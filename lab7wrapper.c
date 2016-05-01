extern int lab7(void);
extern int uart_init(void);
extern int interrupt_init(void);
extern int pin_connect_block_setup(void);
extern int pin_connect_block_setup_for_timer(void);
extern int gpio_direction_setup(void);

int main()
{
	uart_init();
	interrupt_init();
	pin_connect_block_setup_for_timer();
	pin_connect_block_setup();
	gpio_direction_setup();
	lab7();
}
