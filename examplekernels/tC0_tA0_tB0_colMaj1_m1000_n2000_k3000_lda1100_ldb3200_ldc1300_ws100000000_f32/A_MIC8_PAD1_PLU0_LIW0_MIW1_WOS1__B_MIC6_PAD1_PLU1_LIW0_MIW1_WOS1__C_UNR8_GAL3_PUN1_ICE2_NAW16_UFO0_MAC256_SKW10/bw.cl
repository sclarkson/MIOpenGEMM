/* ****************************************************************************
* This copyb kernel string was generated on Thu Jun  8 17:13:31 2017
**************************************************************************** */

/* ***********************************************
* These parameters define WHAT this kernel does *
* *********************************************** */
#define TFLOAT  float
#define LDB 3200
/* less than or equal to LDB, DIM_COAL is size in the contiguous direction (m for c matrix if col contiguous and not transposed) */ 
#define DIM_COAL 3000
/* DIM_UNCOAL is the other dimension of the matrix */ 
#define DIM_UNCOAL 2000

/* ****************************************
 * These parameters define HOW it does it *
 * *****************************************/
/* The number of values from C which each non-edge work-item will scale by beta */
#define WORK_PER_THREAD  2
/* The number of work items per work group */
#define N_WORK_ITEMS_PER_GROUP 256

/* *****************************************************************************
 * The following are all implied by the preceding: these are NOT free parameters!
 * **************************************************************************** */
/*      each (full) work item will process WORK_PER_THREAD elements in the coalesced direction, */ 
/*      so the number of work items per coalesced line is DIM_COAL / WORK_PER_THREAD */ 
#define N_FULL_WORK_ITEMS_PER_LINE 1500
/*      including the possible final tail thread, */
/*      there are N_FULL_WORK_ITEMS_PER_LINE + (DIM_COAL % WORK_PER_THREAD != 0) */ 
#define N_WORK_ITEMS_PER_LINE 1500
/*      in total there are N_FULL_WORK_ITEMS_PER_LINE * DIM_UNCOAL full work items, */ 
#define N_FULL_WORK_ITEMS 3000000
/*      and a grand total of N_WORK_ITEMS_PER_LINE * DIM_UNCOAL work items. */ 
#define N_WORK_ITEMS 3000000
/*      tail work items start at WORK_PER_THREAD * N_FULL_WORK_ITEMS_PER_LINE in the coalesced direction,  */
#define START_IN_COAL_LAST_WORK_ITEM 3000
/*      and process DIM_COAL % WORK_PER_THREAD elements of c */
#define WORK_FOR_LAST_ITEM_IN_COAL 0
/*      the target stride between lines, derived from hp and gg (see DerivedParams) */
#define LDW 3014
#define GLOBAL_OFFSET_W 3033000


__attribute__((reqd_work_group_size(N_WORK_ITEMS_PER_GROUP,1,1)))
__kernel void tg_copyb
(

__global const TFLOAT * restrict b, 
const unsigned b_offset,
__global TFLOAT * restrict w,
const unsigned w_offset)
{
      
      
  /* setting up where this thread works */
  unsigned group_id = get_group_id(0);
  unsigned local_id = get_local_id(0);
  unsigned global_id = group_id*N_WORK_ITEMS_PER_GROUP + local_id; 
  
  unsigned start_uncoal = 0;
  unsigned start_coal = 0;
  
  bool is_in_full_zone = (global_id < N_FULL_WORK_ITEMS);
  
  if (is_in_full_zone){   
    start_uncoal = global_id / N_FULL_WORK_ITEMS_PER_LINE;
    start_coal = WORK_PER_THREAD * (global_id % N_FULL_WORK_ITEMS_PER_LINE);
  }
  
  else if (global_id < N_WORK_ITEMS){
    start_uncoal = (global_id - N_FULL_WORK_ITEMS)% DIM_UNCOAL;
    start_coal = START_IN_COAL_LAST_WORK_ITEM;
  }
  
  
  
  /* moving the b pointer to the first element to process */
  b += b_offset;
  b += start_uncoal * LDB;
  b += start_coal;
  
  
  /* moving the y pointer to the first element to process */
  w += GLOBAL_OFFSET_W;
  w += w_offset;
  w += start_uncoal * LDW;
  w += start_coal;
  
  if (is_in_full_zone){
    #pragma unroll WORK_PER_THREAD
    for (unsigned i = 0; i < WORK_PER_THREAD; ++i){  
      /* the copy */
      w[i] = b[i];
    }
  }
  
  else if (global_id < N_WORK_ITEMS){
    for (unsigned i = 0; i < WORK_FOR_LAST_ITEM_IN_COAL; ++i){  
      /* the copy */
      w[i] = b[i];
    }
  }
  
}


