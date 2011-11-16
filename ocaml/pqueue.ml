#use "pcoord.ml";;

(* A Priority Queue and its supporting functions *)
type pqueue = {order_prop : (pcoord option -> pcoord option) -> bool; mutable heap_arr : pcoord option array};;

let make ordering arr =
    {order_prop = ordering; heap_arr = arr};;

let make ordering =
    make ordering (Array.make 10 None);;

let peek queue =
    queue.heap_arr.(0);;

let rec size_helper arr current_size =
    if Array.length arr > current_size && arr.(current_size) <> None
        then size_helper arr (current_size + 1)
    else current_size;;

let size queue =
    size_helper queue.heap_arr 0;;

let is_empty queue =
    (size queue) = 0;;

let parent_index_of index =
    (index-1)/2;;

let swap queue start_index end_index =
    let temp = queue.heap_arr.(end_index) in
    queue.heap_arr.(end_index) <- queue.heap_arr.(start_index);
    queue.heap_arr.(start_index) <- temp;;

let better queue first second =
    let my_last = (size queue) - 1 in
    if first > my_last || second > my_last || queue.heap_arr.(first) == None
        then false
    else if queue.heap_arr.(second) == None then true
    (* FAILURE *) else queue.order_prop (queue.heap_arr.(first) queue.heap_arr.(second));;

let find_best_child_index queue parent_index =
    let first = 2 * parent_index + 1 in
    let second = first + 1 in
    if better queue first second then first
    else second;;

let rec heap_down queue elem_index =
    let my_last = (size queue) - 1 in
    if elem_index < my_last then
        let child_index = find_best_child_index queue elem_index in
        if better queue child_index elem_index then (
            swap queue elem_index child_index;
            heap_down queue child_index
        );;

let dequeue queue =
    let ret_val = queue.heap_arr.(0) in
    let my_last = (size queue) - 1 in
    queue.heap_arr.(0) <- queue.heap_arr.(my_last);
    queue.heap_arr.(my_last) <- None;
    heap_down queue 0;
    ret_val;;

let double_arr_size queue =
    let my_last = (size queue) - 1 in
    let new_len = 2 * (Array.length queue.heap_arr) in
    let new_arr = Array.make new_len None in
    Array.blit queue.heap_arr 0 new_arr 0 (my_last + 1);
    queue.heap_arr <- new_arr;;

let insert_at_end queue elem =
    let arr_size = (size queue) in
    if arr_size > (Array.length queue.heap_arr) then double_arr_size queue;
    queue.heap_arr.(arr_size) <- Some elem;;

let rec heap_up queue elem_index =
    let parent_index = parent_index_of elem_index in
    if elem_index <> 0 && (better queue elem_index parent_index) then (
        swap queue elem_index parent_index;
        heap_up queue parent_index
    );;

let enqueue queue elem =
    insert_at_end queue elem;
    heap_up queue ((size queue) - 1);;

let rec mem_helper queue elem index end_index =
    if index < end_index then
    match queue.heap_arr.(index) with
        | None -> false
        | Some coord ->
                if (coord.y == elem.y && coord.x == elem.x && coord.priority == elem.priority) then true
                else mem_helper queue elem (index + 1) end_index
    else false;;

let mem queue elem =
    mem_helper queue elem 0 (size queue);;