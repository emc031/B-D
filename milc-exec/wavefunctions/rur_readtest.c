#include<stdio.h>
#include<stdlib.h>

typedef struct {
  double x;
  double y;
} point;

typedef struct {
  long size;
  point *e;
} point_vector;

void resize_point_vector( point_vector* , long );
static point_vector* read_ascii_points ( const char* );
static point_vector* new_point_vector ( long );

int main() {

  const char* filename = "exp3.425_3296.wf";
  point_vector* v = read_ascii_points(filename);

  point* e = v->e;

  point t;
  int n;
  int size = (int) v->size;
  for ( n=0; n < size; n++ ) {
    t = e[n];
    printf("r = %lf, r*psi(r) = %lf\n",t.x,t.y);
  }

  return 0;
}

static point_vector* read_ascii_points ( const char* filename )
{
  point p;
  long cnt;
  long size = 1000; // starting size                                           
  point_vector* v = new_point_vector ( size );
  FILE* fp;
  int status;

    fp = fopen ( filename, "r" );
    if ( fp == NULL )
      {
        printf ( "Open failed: %s\n", filename );
      }

    cnt = 0;
    while ( (status = fscanf ( fp, "%lf%lf", &p.x, &p.y )) != EOF && status != 0 )
      {
        if ( cnt >= size )
          {
            size *= 2; // double the size                              
            printf ( "resizing vector %ld\n", size );
            resize_point_vector ( v, size );
          }

        v -> e [cnt] = p;

        ++cnt;
      }

    if(status != EOF){
      printf("read_ascii_points: format error reading %s\n", filename);
    }

    resize_point_vector ( v, cnt );

    fclose ( fp );

  return v;
}

void resize_point_vector ( point_vector* self, long size )
{
  self -> e = (point *)realloc ( self -> e, size * sizeof (point) );
  self -> size = size;
}


static point_vector* new_point_vector ( long size )
{
  point_vector* self = (point_vector *) malloc ( sizeof (point_vector) );
  self -> size = size;
  self -> e = (point *) malloc ( size * sizeof (point) );

  return self;
}
