int deref_as_int(void* ptr) {
    return *((int*)ptr);
}

void ptr_set_as_int(void* ptr, int value) {
    *((int*)ptr) = value;
}

void* ptr_add_byte_offset(void* ptr, int offset_in_bytes) {
    return (void*)(((unsigned char*)ptr) + offset_in_bytes);
}
