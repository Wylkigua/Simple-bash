#include <stdio.h>
#include <stdlib.h>
#include <getopt.h>
#include <string.h>

#define MAX_LINE_LENGTH 1024

struct flags {
    int b; // --number-nonblank
    int e; // -E
    int n; // --number
    int s; // --squeeze-blank
    int t; // -T
    int v; // who are u...
};

void reset_flags(struct flags *flags) {
    flags->b = 0;
    flags->e = 0;
    flags->n = 0;
    flags->s = 0;
    flags->t = 0;
    flags->v = 0;
}

static const struct option long_options[] = {
    {"number-nonblank", no_argument, 0, 'b'},
    {"number",          no_argument, 0, 'n'},
    {"squeeze-blank",   no_argument, 0, 's'},
    {"v",               no_argument, 0, 'v'},
    {0, 0, 0, 0 }
};

int parse_args(int argc, char **argv, struct flags *flags) {
    int opt;
    int options_index = 0;
    int options_processed = 0;

    while ((opt = getopt_long(argc, argv, "beEnstTv",
    long_options, &options_index)) != -1) {
        switch(opt) {
            case 'b':
                flags->b = 1;
                break;
            case 'e':
                flags->e = 1;
                flags->v = 1; 
                break;
            case 'E':
                flags->e = 1;
                break;
            case 'n':
                flags->n = 1;
                break;
            case 's':
                flags->s = 1;
                break;
            case 't':
                flags->t = 1;
                flags->v = 1; 
            case 'T':
                flags->t = 1;
                break;
            case 'v':
                flags->v = 1;
                break;       
        }
        options_processed++; 
    }
    return options_processed; 
}


void handle_with_flags(FILE *file, struct flags *flags) {
    char buffer[MAX_LINE_LENGTH];
    int line_number = 1;
    int blank_lines_count = 0;

    while (fgets(buffer, sizeof(buffer), file)) {
        size_t len = strlen(buffer);
        size_t elen = strlen(buffer); 
       
      if (len > 0 && buffer[len - 1] == '\n') {
            buffer[len - 1] = '0';  
            len--; 
        }


        if (flags->s && len == 0) {
            blank_lines_count++;
            if (blank_lines_count > 1) continue; 
        } else {
            blank_lines_count = 0; 
        }

        if (flags->n || (flags->b && len > 0)) {
            printf("%6d\t", line_number++);
        }

        for (size_t i = 0; i < len; i++) {
            if (flags->t && buffer[i] == '\t') {
                printf("^I"); 
            }  else if (flags->v && buffer[i] < 32) {
                printf("^%c", buffer[i] + '@');
        } 
           else {
               putchar(buffer[i]); 
           }
        }
       
        if (flags->e && len < elen) {
           putchar('$'); 
        
       }
        putchar('\n'); 

    }
}



int main(int argc, char **argv) {
    struct flags flags;
    reset_flags(&flags); 

    int options_processed = parse_args(argc, argv, &flags);
    
    if (argc - options_processed == 1) { 
        handle_with_flags(stdin, &flags); 
    } else {
        for (int i = options_processed + 1; i < argc; i++) {
            FILE *file = fopen(argv[i], "r");
            if (!file) {
                continue;
            }
            handle_with_flags(file, &flags); 
            fclose(file);
        }
    }
    return 0;
}
