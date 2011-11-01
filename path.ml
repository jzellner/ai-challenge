open Hashtbl;;
open Printf;;

type cell = [`Goal | `Origin | `Empty | `Blocked];;
type direction = [`N | `S | `E | `W];;

let mwidth = 15;;
let mheight = 15;;

let map = 
    [[0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];
    [0;0;0;0;0;0;0;0;0;0;0;0;0;9;0];
    [0;0;1;0;0;0;0;0;0;0;0;0;0;0;0];
    [0;0;1;1;0;0;0;0;0;0;0;0;0;0;0];
    [0;0;1;1;1;1;0;0;0;0;0;0;0;0;0];
    [0;0;0;0;0;1;1;0;0;0;0;0;0;0;0];
    [0;0;0;0;0;0;1;0;0;0;0;0;0;0;0];
    [0;0;0;0;0;0;1;0;0;0;0;0;0;0;0];
    [0;0;0;0;0;0;1;0;0;0;0;0;0;0;0];
    [0;0;0;0;0;0;1;0;0;0;0;1;1;1;1];
    [0;0;0;0;0;0;1;0;0;0;0;1;0;0;0];
    [0;0;0;0;0;0;1;0;1;1;1;1;0;0;0];
    [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];
    [0;0;8;0;0;0;0;0;0;0;0;0;0;0;0];
    [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0]];;

(*let navigate origin dir = function
    | (orr,orc), `N -> (orr-1, orc)
    | (orr,orc), `S -> (orr+1, orc)
    | (orr,orc), `E -> (orr, orc+1)
    | (orr,orc), `W -> (orr, orc-1)

let rec nav_dirs origin dirs = function
    | point, [] -> point
    | point, h::t -> 
        let next = navigate point h in
        nav_dirs next t;;
*)

let cell_of_int ival = 
    if ival = 1 then `Blocked
    else if ival = 8 then `Origin
    else if ival = 9 then `Goal
    else `Empty;;

let sym_of_cell cval =
    if cval = `Blocked then "*"
    else if cval = `Origin then "O"
    else if cval = `Goal then "G"
    else " ";;

let rec print_point_list plist acc = 
    match plist with
    | [] -> Printf.printf "%s\n" acc
    | (hr,hc) :: t ->
        print_point_list t ( (Printf.sprintf "(%d,%d) " hr hc) ^ acc);;

let cells_from (r,c) =
    let pot = [ (r-1, c); (r, c-1); (r, c+1); (r+1, c); ] in
    let valid (fr,fc) = 
        (fr >= 0) && (fr < mheight) && (fc >= 0) && (fc < mwidth) in
    List.filter valid pot;;

let new_cells_from loc known =
    let temp = cells_from loc in
    let valid el = not (List.mem el known) in
    List.filter valid temp;;

let print_map mdat = 
    for i = 0 to mheight - 1 do
        for j = 0 to mwidth - 1 do
            Printf.printf "%s" (sym_of_cell (Hashtbl.find mdat (i,j)))
        done;
        Printf.printf "\n"
    done;;

let populate_data () = 
    let origin = Hashtbl.create 1 in
    let goal = Hashtbl.create 1 in
    let dat = Hashtbl.create (mwidth * mheight) in
    let ar = map in
    for i = 0 to (List.length ar) - 1 do
        let row = List.nth ar i in
        for j = 0 to (List.length row) - 1 do
            let v = List.nth row j in
            let ctype = cell_of_int v in
            if ctype = `Origin then Hashtbl.add origin `Origin (i,j);
            if ctype = `Goal then Hashtbl.add goal `Goal (i,j);
            Hashtbl.add dat (i,j) (cell_of_int v);
        done;
    done;
    (origin, goal, dat);;

let abs v = 
    if v < 0 then -v
    else v;;

let cost (orr,orc) (nr,nc) = abs (orr - nr) + abs (orc - nc);;

let explore map (orr,orc) (gr,gc) =
    let frontier = cells_from (orr,orc) in
    List.iter (fun (xr,xc) ->
        Printf.printf "(%d,%d) -> (%d,%d) = %d\n" orr orc xr xc 
            (cost (orr,orc) (xr,xc))) frontier;;


(*let rec explore map (sr,sc) (gr, gc) known path =
    if sr = gr && sc = gc 
        then (List.length known, path) 
    else
        let next = new_cells_from (sr,sc) known in
        let rec inner mnext =
            match mnext with
            | [] -> ()
            | (nr,nc) :: t ->
                    explore map (nr,nc) (gr,gc) (nr,nc)::known (nr,nc)::path; 
                    ()
                        print_point_list next "";*)

let _ = 
    let (origin, goal, mdat) = populate_data () in
    let (orr,orc) = Hashtbl.find origin `Origin in
    let (gr,gc) = Hashtbl.find goal `Goal in
    Printf.printf "Origin at (%d,%d)\n" orr orc;
    Printf.printf "Goal at (%d,%d)\n" gr gc;
    explore mdat (orr,orc) (gr,gc);;

(*    print_point_list (new_cells_from (orr,orc) [(14,3)]) "";
    print_point_list (cells_from (orr,orc)) "" 
    (*print_map mdat*)
;;*)
