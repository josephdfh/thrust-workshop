#include <vector>
#include <cstdlib>
#include <iostream>

// TODO: annotate this function with __host__ __device__ so
//       so that they are able to work with Thrust
float2 operator+(float2 a, float2 b)
{
  return make_float2(a.x + b.x, a.y + b.y);
}


void generate_random_points(std::vector<float2> &points)
{
  // sequentially generate some random 2D points in the unit square
  // TODO: parallelize this loop using thrust::tabulate and thrust::default_random_engine
  for(int i = 0; i < points.size(); ++i)
  {
    float x = float(rand()) / RAND_MAX;
    float y = float(rand()) / RAND_MAX;

    points[i] = make_float2(x,y);
  }
}


float2 compute_centroid(const std::vector<float2> &points)
{
  float2 result = make_float2(0,0);

  // compute the mean
  // TODO: parallelize this sum using thrust::reduce
  for(int i = 0; i < points.size(); ++i)
  {
    result = result + points[i];
  }

  return make_float2(result.x / points.size(), result.y / points.size());
}


void classify(const std::vector<float2> &points, float2 centroid, std::vector<int> &quadrants)
{
  // classify each point relative to the centroid
  // TODO: parallelize this loop using thrust::transform
  for(int i = 0; i < points.size(); ++i)
  {
    float x = points[i].x;
    float y = points[i].y;

    // bottom-left:  0
    // bottom-right: 1
    // top-left:     2
    // top-right:    3

    quadrants[i] = (x <= centroid.x ? 0 : 1) | (y <= centroid.y ? 0 : 2);
  }
}


void count_points_in_quadrants(std::vector<float2> &points, std::vector<int> &quadrants, std::vector<int> &counts_per_quadrant)
{
  // sequentially compute a histogram
  // TODO: parallelize this operation by
  //   1. sorting points by quadrant
  //   2. reducing points by quadrant
  for(int i = 0; i < quadrants.size(); ++i)
  {
    int q = quadrants[i];

    // increment the number of points in this quadrant
    counts_per_quadrant[q]++;
  }
}


std::ostream &operator<<(std::ostream &os, float2 p)
{
  return os << "(" << p.x << ", " << p.y << ")";
}


int main()
{
  const size_t num_points = 10;

  // TODO move these points to the GPU by using thrust::device_vector
  std::vector<float2> points(num_points);

  generate_random_points(points);

  for(int i = 0; i < points.size(); ++i)
    std::cout << "points[" << i << "]: " << points[i] << std::endl;
  std::cout << std::endl;

  float2 centroid = compute_centroid(points);

  // TODO move these quadrants to the GPU using thrust::device_vector
  std::vector<int> quadrants(points.size());
  classify(points, centroid, quadrants);

  // TODO move these counts to the GPU using thrust::device_vector
  std::vector<int> counts_per_quadrant(4);
  count_points_in_quadrants(points, quadrants, counts_per_quadrant);

  std::cout << "Per-quadrant counts:" << std::endl;
  std::cout << "  Bottom-left : " << counts_per_quadrant[0] << " points" << std::endl;
  std::cout << "  Bottom-right: " << counts_per_quadrant[1] << " points" << std::endl;
  std::cout << "  Top-left    : " << counts_per_quadrant[2] << " points" << std::endl;
  std::cout << "  Top-right   : " << counts_per_quadrant[3] << " points" << std::endl;
  std::cout << std::endl;

  for(int i = 0; i < points.size(); ++i)
    std::cout << "points[" << i << "]: " << points[i] << std::endl;
  std::cout << std::endl;
}

