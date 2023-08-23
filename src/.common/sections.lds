MEMORY
{
    RAM   (rw) : ORIGIN = 0x00000000, LENGTH = 0x00002000 /* 8 KiB */
    FLASH (rx) : ORIGIN = 0x00050000, LENGTH = 0x00100000 /* entire flash, 1 MiB */
}

SECTIONS {
    .text :
    {
        . = ALIGN(4);
        *(.text .text.*)                         /* program code */
        *(.rodata .rodata.* .srodata .srodata.*) /* read only data */
        *(.eh_frame .eh_frame.*)   
        . = ALIGN(4);
        _text_end = .;        /* define a global symbol at end of code */
        _init_data_start = _text_end;  /* This is used by the startup in order to initialize the .data secion */
    } >FLASH

    /* This is the initialized data section
    The program executes knowing that the data is in the RAM
    but the loader puts the initial values in the FLASH (inidata).
    It is one task of the startup to copy the initial values from FLASH to RAM. */
    .data : AT ( _init_data_start )
    {
        . = ALIGN(4);
        _data_start = .;
        _ram_start = .;
        *(.data .data.* .sdata .sdata.*)
        _init_array_start = .;
        *(.init_array .init_array.*)
        _init_array_end = .;
        . = ALIGN(4);
        _data_end = .;
    } >RAM

    /* Uninitialized data section */
    .bss :
    {
        . = ALIGN(4);
        _bss_start = .;
        *(.bss .bss.* .sbss .sbss.*)
        *(COMMON)
        . = ALIGN(4);
        _bss_end = .;         /* define a global symbol at bss end; used by startup code */
    } >RAM

    /* this is to define the start of the heap, and make sure we have a minimum size */
    .heap :
    {
        . = ALIGN(4);
        _heap_start = .;    /* define a global symbol at heap start */
    } >RAM
}
