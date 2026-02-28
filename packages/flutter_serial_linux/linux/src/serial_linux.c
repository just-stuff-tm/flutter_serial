#include <termios.h>
#include <fcntl.h>
#include <unistd.h>
#include <dirent.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define EXPORT __attribute__((visibility("default")))

EXPORT int open_serial(const char* path, int baudrate) {
  int fd = open(path, O_RDWR | O_NOCTTY);
  if (fd < 0) return -1;

  struct termios tty;
  if (tcgetattr(fd, &tty) != 0) {
    close(fd);
    return -1;
  }

  cfmakeraw(&tty);

  speed_t speed = B115200;
  switch (baudrate) {
    case 9600: speed = B9600; break;
    case 19200: speed = B19200; break;
    case 38400: speed = B38400; break;
    case 57600: speed = B57600; break;
    case 115200: speed = B115200; break;
#ifdef B230400
    case 230400: speed = B230400; break;
#endif
  }

  cfsetispeed(&tty, speed);
  cfsetospeed(&tty, speed);
  tty.c_cc[VMIN] = 1;
  tty.c_cc[VTIME] = 0;

  if (tcsetattr(fd, TCSANOW, &tty) != 0) {
    close(fd);
    return -1;
  }

  return fd;
}

EXPORT int read_serial(int fd, unsigned char* buffer, int maxlen) {
  return (int)read(fd, buffer, maxlen);
}

EXPORT int write_serial(int fd, const unsigned char* data, int length) {
  return (int)write(fd, data, length);
}

EXPORT int close_serial(int fd) {
  return close(fd);
}

EXPORT int scan_devices(char*** out_list, int* out_count) {
  DIR* dir = opendir("/dev");
  if (!dir) return -1;

  int capacity = 16;
  int count = 0;
  char** list = (char**)malloc(sizeof(char*) * capacity);
  if (!list) {
    closedir(dir);
    return -1;
  }

  struct dirent* entry;
  while ((entry = readdir(dir)) != NULL) {
    if (strncmp(entry->d_name, "ttyS", 4) == 0 ||
        strncmp(entry->d_name, "ttyUSB", 6) == 0 ||
        strncmp(entry->d_name, "ttyACM", 6) == 0) {

      if (count == capacity) {
        capacity *= 2;
        char** new_list = (char**)realloc(list, sizeof(char*) * capacity);
        if (!new_list) break;
        list = new_list;
      }

      size_t len = strlen(entry->d_name) + 6;
      char* full = (char*)malloc(len);
      if (!full) break;

      strcpy(full, "/dev/");
      strcat(full, entry->d_name);

      list[count++] = full;
    }
  }

  closedir(dir);
  *out_list = list;
  *out_count = count;
  return 0;
}

EXPORT void free_scan_list(char** list, int count) {
  if (!list) return;
  for (int i = 0; i < count; i++) {
    free(list[i]);
  }
  free(list);
}
