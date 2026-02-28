#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>

#define EXPORT __attribute__((visibility("default")))

static speed_t _map_baud(int baudrate) {
  switch (baudrate) {
    case 9600:
      return B9600;
    case 19200:
      return B19200;
    case 38400:
      return B38400;
    case 57600:
      return B57600;
#ifdef B230400
    case 230400:
      return B230400;
#endif
    default:
      return B115200;
  }
}

EXPORT int open_serial(const char* path, int baudrate) {
  int fd = open(path, O_RDWR | O_NOCTTY);
  if (fd < 0) {
    return -1;
  }

  struct termios tty;
  if (tcgetattr(fd, &tty) != 0) {
    close(fd);
    return -1;
  }

  cfmakeraw(&tty);
  const speed_t speed = _map_baud(baudrate);
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

static int _matches_prefix(const char* name, const char* prefix) {
  return strncmp(name, prefix, strlen(prefix)) == 0;
}

EXPORT int scan_devices(char*** out_list, int* out_count) {
  DIR* dir = opendir("/dev");
  if (!dir) {
    return -1;
  }

  int capacity = 16;
  int count = 0;
  char** list = (char**)malloc(sizeof(char*) * capacity);
  if (!list) {
    closedir(dir);
    return -1;
  }

  struct dirent* entry;
  const char* prefixes[] = {"cu.", "tty."};
  const size_t prefix_count = sizeof(prefixes) / sizeof(prefixes[0]);

  while ((entry = readdir(dir)) != NULL) {
    for (size_t i = 0; i < prefix_count; i++) {
      if (_matches_prefix(entry->d_name, prefixes[i])) {
        if (count == capacity) {
          capacity *= 2;
          char** new_list = (char**)realloc(list, sizeof(char*) * capacity);
          if (!new_list) {
            break;
          }
          list = new_list;
        }

        const size_t len = strlen(entry->d_name) + 6;
        char* full = (char*)malloc(len);
        if (!full) {
          break;
        }

        strcpy(full, "/dev/");
        strcat(full, entry->d_name);
        list[count++] = full;
        break;
      }
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
