; Test suite for MPB.  This file runs MPB for a variety of cases,
; and compares it against known results from previous versions.  If the
; answers aren't sufficiently close, it exits with an error.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Some general setup and utility routines first:

(set! tolerance 1e-9) ; use a low tolerance to get consistent results

; function to check if two results are sufficently close:
(define (almost-equal? x y)
  (or 
   (< (abs (- x y)) (* 1e-5 (+ (abs x) (abs y))))
   (and (< (abs x) 1e-3) (< (abs (- x y)) 1e-3))))

; Convert a list l into a list of indices '(1 2 ...) of the same length.
(define (indices l)
  (if (null? l)
      '()
      (cons 1 (map (lambda (x) (+ x 1)) (indices (cdr l))))))

; Check whether the freqs returned by a run (all-freqs) match correct-freqs.
(define (check-freqs correct-freqs)
  (define (check-freqs-aux fc-list f-list ik)
    (define (check-freqs-aux2 fc f ib)
      (if (not (almost-equal? fc f))
	  (error "check-freqs: k-point " ik " band " ib " is "
		 f " instead of " fc)))
    (if (= (length fc-list) (length f-list))
	(map check-freqs-aux2 fc-list f-list (indices f-list))
	(error "check-freqs: wrong number of bands at k-point " ik)))
  (if (= (length correct-freqs) (length all-freqs))
      (begin
	(map check-freqs-aux correct-freqs all-freqs (indices all-freqs))
	(display "check-freqs: PASSED\n"))
      (error "check-freqs: wrong number of k-points")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; First test: a simple 1d Bragg mirror:

(display-many
 "**************************************************************************\n"
 " Test case: 1d quarter-wave stack.\n"
 "**************************************************************************\n"
)

(set! geometry (list (make cylinder (material (make dielectric (epsilon 9.0)))
			   (center 0) (axis 1)
			   (radius infinity) (height 0.25))))
(set! k-points (interpolate 4 (list (vector3 0 0 0) (vector3 0.5 0 0))))
(set! grid-size (vector3 32 1 1))
(set! num-bands 8)

(define correct-freqs '((6.71526498584553e-6 0.648351062968237 0.666667518888667 1.29488075673619 1.33336075480093 1.93757672851408 2.00024045562498 2.57413377739862) (0.0567106459395599 0.599851835768395 0.715264618493032 1.25335163284172 1.37508036417516 1.90230303083039 2.03577843671071 2.54476073144309) (0.111808338549778 0.54496403537056 0.77047013248268 1.19886555431273 1.43019048406127 1.84869942534301 2.09026194963917 2.4930518553253) (0.162554443030995 0.494234387214999 0.821807214979032 1.14762423868066 1.48265526473299 1.7965649947526 2.14420182927271 2.44000721223445) (0.202728586444533 0.454051807431862 0.862903053647561 1.1065252897017 1.52568848270995 1.75360874628753 2.19029794218109 2.3942414201896) (0.219409188989471 0.437366603189745 0.880190598314617 1.08923081762878 1.5443398403343 1.7349704450792 2.21143711778794 2.3731975719957)))

(run-tm)
(check-freqs correct-freqs)

(run-te)
(check-freqs correct-freqs)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Square lattice of dielectric rods in air.

(display-many
 "**************************************************************************\n"
 " Test case: Square lattice of dielectric rods in air.\n"
 "**************************************************************************\n"
)

(set! geometry (list
		(make cylinder (material (make dielectric (epsilon 11.56))) 
		      (center 0 0) (radius 0.2) (height infinity))))
(set! k-points (interpolate 4 (list (vector3 0) (vector3 0.5)
				    (vector3 0.5 0.5 0) (vector3 0))))
(set! grid-size (vector3 32 32 1))
(set! num-bands 8)

(run-te)
(display-many "all-freqs: " all-freqs "\n")
(check-freqs '((8.62548076930306e-5 0.567309268691387 0.785322487947116 0.785339097139912 0.91906532722133 1.01180234703471 1.01180446096116 1.09869893346954) (0.0897475334038327 0.565478962888668 0.770909925605609 0.786976045234942 0.911716296170874 1.00922747575042 1.01332658108679 1.1220477608322) (0.178766635065283 0.558183927761956 0.733727796485694 0.791352310580068 0.894869659565541 1.01797556870978 1.0183149224556 1.12431478890177) (0.266049753476525 0.538687892094833 0.690403576062145 0.796919728741056 0.879307985310929 1.02568655836423 1.04031515320341 1.11602169030508) (0.349608570982076 0.496962222791024 0.660679622049494 0.801560565910111 0.869495965837543 1.03500247636448 1.06884798601043 1.10467620761782) (0.413082417117352 0.446395530337967 0.651450595073183 0.803368099819891 0.866189516688409 1.04010576541785 1.09753776037996 1.09827456525765) (0.424034318475701 0.450850117081374 0.647112289739004 0.807637589363958 0.861158579963818 0.994174145544902 1.0595794172637 1.11992767773815) (0.455082616824107 0.463338791124478 0.635212403292712 0.819735856354932 0.838315627232708 0.939938902646523 1.01486587270942 1.12838695905208) (0.481198597820566 0.501609229763061 0.618522175753188 0.786155073927436 0.838317450345751 0.913939091232548 0.970884228080751 1.13184861079898) (0.499280260937176 0.556434275007696 0.601659180916135 0.721570044167946 0.862218793047699 0.905816154022519 0.931039089966407 1.13347236398633) (0.507900932587 0.593526292833574 0.593596593124933 0.680566062367046 0.88387598815364 0.903945296603266 0.903949249935734 1.13397288782519) (0.476628236569602 0.551926957646813 0.607311768805224 0.746127961399139 0.85247945528518 0.903785999923617 0.949896076238275 1.13279836961847) (0.373412079642824 0.547353877862404 0.645745076852373 0.820546048524795 0.83382122625854 0.903647721699651 1.02088954489018 1.12643735967833) (0.252290144958668 0.555861520941481 0.701023986684804 0.802063555906004 0.904841846692795 0.906101988454332 1.09483334397003 1.10211421754981) (0.126868830236268 0.564051618328441 0.75794308251239 0.789566003897489 0.910582192714606 0.971875854812311 1.04852328393724 1.12559272973883) (9.43897424323217e-6 0.567309249859068 0.785322467992737 0.785339072102688 0.91906531540291 1.01180231504848 1.01180439606364 1.09869875575488)))

(run-tm)
(check-freqs '((6.60563758124023e-6 0.550430733573744 0.566241371598517 0.566241372163083 0.835198392616276 0.872522248604954 0.972318183067969 1.08920254582846) (0.0654861239999524 0.527080481417842 0.566799276751695 0.589165207613099 0.835576055449094 0.87098006256428 0.960846516331784 1.05902201035235) (0.128358448231762 0.495999172056422 0.568271183796952 0.619721421825485 0.83356296054228 0.867048180733247 0.930077475889247 1.04306779424379) (0.185088034665959 0.463940092597232 0.570113900868757 0.653567078126228 0.817881354346978 0.86237241198514 0.90187550142523 1.04123744478054) (0.229126816125476 0.435593887869437 0.571624367586528 0.691156829464894 0.782224998842117 0.858716310201943 0.891825123400888 1.04461063360963) (0.247300696006748 0.422810121349707 0.572206120768815 0.722519491352313 0.749366763369664 0.857346110926566 0.89039153967379 1.0468678713734) (0.250809748878833 0.429554276590146 0.565096567434358 0.720355410169051 0.758471422549885 0.858178250955783 0.89048836021277 1.03491655457074) (0.260255079137602 0.448078995516004 0.547933657276557 0.713707158688594 0.782090347346112 0.86101638088251 0.890741336275652 1.00608368845576) (0.272587744232562 0.47336409254549 0.528315799682106 0.702811847529422 0.814130266536549 0.866746367067701 0.891050068065077 0.969737885038821) (0.28329017996901 0.496884116939824 0.512907153651487 0.690607961839941 0.850483079390604 0.87601118335254 0.891266436139031 0.930779872994139) (0.287601798196358 0.507006838456059 0.507006838475393 0.684706840348945 0.883530037853842 0.883530037866573 0.889824048148961 0.898389144733935) (0.277734985850212 0.494789217195799 0.512794766069263 0.693585317484579 0.841827176583588 0.865559776647151 0.91182965298438 0.913648622072292) (0.241654191448818 0.481926694377318 0.527837662343769 0.687466863320862 0.831639003520604 0.85055138175555 0.915313305877232 0.946702579779499) (0.176222602981778 0.490886438976767 0.546175771973786 0.650073604194652 0.841125231854928 0.853522369326248 0.92744923560386 0.98745618288734) (0.092014400204003 0.518511998133382 0.560750416146475 0.604065528188571 0.836485468004984 0.868856191329737 0.954250999892415 1.03716877067079) (9.02424482777878e-6 0.550430733302961 0.566241371575915 0.566241372128928 0.835198392515826 0.8725222485131 0.972318183006073 1.0892025381508)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Using the targeted solver to find a defect state in a 5x5 triangular
; lattice of rods.

(display-many
 "**************************************************************************\n"
 " Test case: 5x5 triangular lattice of rods in air, dipole defect states.\n"
 "**************************************************************************\n"
)

(set! geometry-lattice (make lattice (size 5 5 1)
                         (basis1 (/ (sqrt 3) 2) 0.5)
                         (basis2 (/ (sqrt 3) 2) -0.5)))
(set! k-points (list (vector3 (/ -3) (/ 3) 0))) ; K
(set! geometry (list
		(make cylinder (material (make dielectric (epsilon 12))) 
		      (center 0 0) (radius 0.2) (height infinity))))
(set! geometry (geometric-objects-lattice-duplicates geometry))
(set! geometry (append geometry 
                       (list (make cylinder (center 0 0 0) 
                                   (radius 0.33) (height infinity)
                                  (material (make dielectric (epsilon 12)))))))
(set! grid-size (vector3 (* 16 5) (* 16 5) 1))
(set! num-bands 2)
(set! target-freq 0.36)
(run-tm)
(check-freqs '((0.336475393040572 0.337004058467282)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display-many
 "**************************************************************************\n"
 " Test case: fcc lattice of air spheres in dielectric.\n"
 "**************************************************************************\n"
)

(set! geometry-lattice (make lattice
			 (basis1 0 1 1)
			 (basis2 1 0 1)
			 (basis3 1 1 0)))
(set! k-points (interpolate 1 (list
			       (vector3 0 0.5 0.5)            ; X
			       (vector3 0 0.625 0.375)        ; U
			       (vector3 0 0.5 0)              ; L
			       (vector3 0 0 0)                ; Gamma
			       (vector3 0 0.5 0.5)            ; X
			       (vector3 0.25 0.5 0.75)        ; W
			       (vector3 0.375 0.375 0.75))))  ; K
(set! geometry (list (make sphere (center 0) (radius 0.5) (material air))))
(set! default-material (make dielectric (epsilon 11.56)))
(set! grid-size (vector3 16 16 16))
(set! mesh-size 5)
(set! num-bands 10)
(run)
(check-freqs '((0.36740266120816 0.369423419557983 0.380313489679436 0.3818216501707 0.494027883609878 0.511501075197029 0.520229780059488 0.522932480632918 0.589746021792143 0.654835118384378) (0.365497816716618 0.374846395891662 0.383087873859041 0.385343065924314 0.470674067307498 0.505277703714121 0.521921462734047 0.530870719697934 0.605858443454724 0.638232374511377) (0.354749117316649 0.378725119472235 0.390251662577336 0.399430581363773 0.437685823920157 0.493067188428436 0.525995000177792 0.541190506758158 0.633263715515043 0.633813372373362) (0.320987909849108 0.329071009556332 0.395772119559967 0.398988043350952 0.461982696666239 0.512849967722734 0.532365884858942 0.546797402152528 0.628260953602865 0.639702463113998) (0.304734378532973 0.306384394851798 0.385239546039279 0.387808575975424 0.491972006596066 0.535492408967796 0.536299419341307 0.539095240499526 0.621890754085433 0.624216956740668) (0.177788476567772 0.178678096986619 0.47190121311717 0.475341503162068 0.504265405811503 0.53516068631247 0.538175421517073 0.540417555256511 0.621112008682908 0.622686007544725) (6.13166693600701e-6 8.05511702096386e-6 0.518581770964319 0.523323616813286 0.523323618095213 0.543982772186965 0.543982772876901 0.546986800247467 0.606491040890839 0.608970040343773) (0.205113618431216 0.205886305557539 0.472124866705332 0.474834060100379 0.507589563683485 0.526412357235264 0.529117716786996 0.531758018602072 0.599247235169019 0.652754361877104) (0.367402661208136 0.369423419557954 0.380313489679422 0.381821650170703 0.494027883609782 0.51150107519685 0.520229780059476 0.522932480632863 0.589746021791715 0.654835118382045) (0.369565262202954 0.374481167102769 0.38369086050624 0.390873134430402 0.462133818158507 0.500580314645478 0.503601584636612 0.549325604661139 0.617406905049141 0.628360351989734) (0.370958459158381 0.384024089882822 0.384275113488983 0.408169159107744 0.433781488750729 0.488692363460369 0.490307718128851 0.56835744403604 0.616857025429936 0.650969493279547) (0.361712552864854 0.380486775489389 0.38729205679082 0.404018430489697 0.436900280433716 0.491985824196426 0.503492371442705 0.560332683818721 0.623835841308089 0.641035087393266) (0.356604717484288 0.377841304835848 0.388488279802544 0.400930271954659 0.436439184605941 0.493532186130499 0.528401192977172 0.540885848254659 0.63412416995121 0.634772774300151)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display-many
 "**************************************************************************\n"
 " Test case: simple cubic lattice with anisotropic dielectric.\n"
 "**************************************************************************\n"
)

(set! k-points (list (vector3 0) (vector3 0.5)
		     (vector3 0.5 0.5) (vector3 0.5 0.5 0.5)))
(set! grid-size (vector3 16 16 16))
(set! mesh-size 5)
(define hi-all (make dielectric (epsilon 12)))
(define hi-x (make dielectric-anisotropic (epsilon-diag 12 1 1)))
(define hi-y (make dielectric-anisotropic (epsilon-diag 1 12 1)))
(define hi-z (make dielectric-anisotropic (epsilon-diag 1 1 12)))
(set! geometry
	(list (make block (center 0) (size 0.313 0.313 1) (material hi-z))
	      (make block (center 0) (size 0.313 1 0.313) (material hi-y))
	      (make block (center 0) (size 1 0.313 0.313) (material hi-x))
	      (make block (center 0) (size 0.313 0.313 0.313) 
		    (material hi-all))))
(set! num-bands 3)
(run)

(check-freqs '((6.66222251456307e-6 6.66227566476e-6 0.546007449856072) (0.250204027316874 0.250204027316909 0.427550121407706) (0.290604311903622 0.333913084881104 0.477111252827531) (0.351288161127344 0.351288161127375 0.480258484218935)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(display "PASSED all tests.\n")
