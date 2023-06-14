;------------------------------------------------------------------------------
; Define dynamic variables:
;------------------------------------------------------------------------------
(def *clojure-repl* false)

;------------------------------------------------------------------------------
; Create standard calls from special forms:
;------------------------------------------------------------------------------
(defmacro! defmacro
  (fn* [name & body]
    `(defmacro! ~name
      (fn* ~@body))))

(defmacro fn [& xs] (cons 'fn* xs))

(defmacro defn [name & body]
  `(def ~name (fn ~@body)))

(defmacro let [& xs] (cons 'let* xs))

(defmacro import [& xs] (cons 'import* xs))

; (defmacro assert-args
;   [& pairs]
;   `(do (when-not ~(first pairs)
;          (throw (IllegalArgumentException.
;                   (str (first ~'&form) " requires " ~(second pairs) " in " ~'*ns* ":" (:line (meta ~'&form))))))
;      ~(let [more (nnext pairs)]
;         (when more
;           (list* `assert-args more)))))
;
; (defmacro let
;   [bindings & body]
;   (assert-args
;      (vector? bindings) "a vector for its binding"
;      (even? (count bindings)) "an even number of forms in binding vector")
;   `(let* ~(destructure bindings) ~@body))

(defmacro try [& xs] (cons 'try* xs))

; (defmacro ..
;   ([x form] `(. ~x ~form))
;   ([x form & more] `(.. (. ~x ~form) ~@more)))

;------------------------------------------------------------------------------
; Lingy specific functions:
;------------------------------------------------------------------------------
(defn clojure-repl-on [] (def *clojure-repl* true) nil)
(defn clojure-repl-off [] (def *clojure-repl* false) nil)

;------------------------------------------------------------------------------
; Basic math ops:
;------------------------------------------------------------------------------
(defn +
  ([] 0)
  ([x] x)
  ([x y] (. lingy.lang.Numbers (add x y)))
  ([x y & more]
    (reduce + (+ x y) more)))

(defn -
  ([] 0)
  ([x] (lingy.lang.Numbers/minus 0 x))
  ([x y] (. lingy.lang.Numbers (minus x y)))
  ([x y & more]
    (reduce - (- x y) more)))

(defn *
  ([x] x)
  ([x y] (. lingy.lang.Numbers (multiply x y)))
  ([x y & more]
    (reduce * (* x y) more)))

(defn /
  ([x] (/ 1 x))
  ([x y] (. lingy.lang.Numbers (divide x y)))
  ([x y & more]
    (reduce / (/ x y) more)))

(defn =
  ([x] true)
  ([x y] (lingy.lang.Util/equiv x y))
  ([x y & more]
    (if (= x y)
      (if (next more)
        (recur y (first more) (next more))
        (= y (first more)))
      false)))

(defn not=
  ([x] false)
  ([x y] (not (= x y)))
  ([x y & more]
    (not (apply = x y more))))

(defn ==
  ([x] true)
  ([x y] (lingy.lang.Numbers/equiv x y))
  ([x y & more]
    (if (< x y)
      (if (next more)
        (recur y (first more) (next more))
        (< y (first more)))
      false)))

(defn <
  ([x] true)
  ([x y] (lingy.lang.Numbers/lt x y))
  ([x y & more]
    (if (< x y)
      (if (next more)
        (recur y (first more) (next more))
        (< y (first more)))
      false)))

(defn <=
  ([x] true)
  ([x y] (lingy.lang.Numbers/lte x y))
  ([x y & more]
    (if (<= x y)
      (if (next more)
        (recur y (first more) (next more))
        (<= y (first more)))
      false)))

(defn >
  ([x] true)
  ([x y] (lingy.lang.Numbers/gt x y))
  ([x y & more]
    (if (> x y)
      (if (next more)
        (recur y (first more) (next more))
        (> y (first more)))
      false)))

(defn >=
  ([x] true)
  ([x y] (lingy.lang.Numbers/gte x y))
  ([x y & more]
    (if (>= x y)
      (if (next more)
        (recur y (first more) (next more))
        (>= y (first more)))
      false)))

;------------------------------------------------------------------------------
; Other macros and functions:
;------------------------------------------------------------------------------
(defmacro ->
  [x & forms]
  (loop [x x, forms forms]
    (if forms
      (let [form (first forms)
            threaded (
              if (seq? form)
                `(~(first form) ~x ~@(next form))
                (list form x))]
        (recur threaded (next forms)))
      x)))

(defmacro ->>
  [x & forms]
  (loop [x x, forms forms]
    (if forms
      (let [form (first forms)
            threaded (
              if (seq? form)
                `(~(first form) ~@(next form) ~x)
                (list form x))]
        (recur threaded (next forms)))
      x)))

; (defn all-ns [] (lingy.lang.Namespace/all))
(defn all-ns [] (lingy.lang.RT/all_ns))

(defmacro and
  ([] true)
  ([x] x)
  ([x & next]
   `(let [and# ~x]
      (if and# (and ~@next) and#))))

(defn apply [f & args] (. lingy.lang.RT (apply f args)))

(defn assoc
  ([map key val] (lingy.lang.RT/assoc map key val))
  ; XXX use recur when available in fn
  ([map key val & kvs]
    (let [ret (assoc map key val)]
      (apply assoc ret (first kvs) (second kvs) (nnext kvs)))))

(defn atom [x] (. lingy.lang.RT (atom_ x)))
; XXX Should be:
; (defn atom [x] (new lingy.lang.Atom x))

(defn boolean [x] (. lingy.lang.RT (booleanCast x)))

(defn boolean? [x] (instance? lingy.lang.Boolean x))

(defn char [x] (. lingy.lang.RT (charCast x)))

(defn class? [x] (instance? lingy.lang.Class x))

(defn clojure-version []
  (str
    (:major *clojure-version*)
    "."
    (:minor *clojure-version*)
    (when-let [i (:incremental *clojure-version*)]
      (str "." i))
    (when-let [q (:qualifier *clojure-version*)]
      (when (pos? (count q)) (str "-" q)))
    (when (:interim *clojure-version*)
      "-SNAPSHOT")))

(defn concat [& args] (apply lingy.lang.RT/concat args))

(defmacro cond [& xs]
  (if (> (count xs) 0)
    (list 'if (first xs)
      (if (> (count xs) 1)
        (nth xs 1)
        (throw "odd number of forms to cond"))
      (cons 'cond (rest (rest xs))))))

(defmacro comment [& body] nil)

(defn conj [& args] (apply lingy.lang.RT/conj args))

(defn contains? [coll key] (. lingy.lang.RT (contains coll key)))

(defn count [list] (. lingy.lang.RT (count list)))

(defn create-ns [symbol] (. lingy.lang.RT (create_ns symbol)))

(defn dec [x] (. lingy.lang.RT (dec x)))

(defmacro declare [& names]
  `(do
    ~@(map
      #(list 'def %)
      names)))

(defn deref [x] (. lingy.lang.RT (deref x)))

(defn dissoc [& args] (apply lingy.lang.RT/dissoc args))

(defmacro doto
  [x & forms]
    (let [gx (gensym)]
      `(let [~gx ~x]
        ~@(map (fn [f]
          (if (seq? f)
            `(~(first f) ~gx ~@(next f))
            `(~f ~gx)))
          forms)
        ~gx)))

(defn empty? [coll] (not (seq coll)))

(defn false? [x] (lingy.lang.Util/identical x false))

(defn ffirst [x] (first (first x)))

(defn find-ns [name] (. lingy.lang.RT (find_ns name)))

(defn first [list] (. lingy.lang.RT (first list)))

(defn fn? [x] (instance? lingy.lang.Fn x))

(defn fnext [x] (first (next x)))

(defn get [map key & default] (apply lingy.lang.RT/get map key default))

(defn getenv [key] (. lingy.lang.RT (getenv key)))

(defn gensym
  ([] (gensym "G__"))
  ([prefix-string]
    (. lingy.lang.Symbol
      (intern
        (str
          prefix-string
          (str (. lingy.lang.RT (nextID))))))))

(defn hash-map [& args] (apply lingy.lang.RT/hash_map args))

(defn hash-set [& args] (apply lingy.lang.RT/hash_set args))

(defn identity [x] x)

(defn in-ns [name] (. lingy.lang.RT (in_ns name)))

(defn inc [num] (. lingy.lang.RT (inc num)))

(defn instance? [c x] (. c (isInstance x)))

(defn keys [map] (. lingy.lang.RT (keys_ map)))

(defn keyword [string] (. lingy.lang.RT (keyword_ string)))

(defn keyword? [x] (instance? lingy.lang.Keyword x))

(defn lingy-version []
  (str
    (:major *lingy-version*)
    "."
    (:minor *lingy-version*)
    (when-let [i (:incremental *lingy-version*)]
      (str "." i))
    (when-let [q (:qualifier *lingy-version*)]
      (when (pos? (count q)) (str "-" q)))
    (when (:interim *lingy-version*)
      "-SNAPSHOT")))

(defn list [& args] (apply lingy.lang.RT/list_ args))

(defn list? [x] (instance? lingy.lang.List x))

(defn list*
  ([args] (seq args))
  ([a args] (cons a args))
  ([a b args] (cons a (cons b args)))
  ([a b c args] (cons a (cons b (cons c args))))
  ([a b c d & more]
    (cons a (cons b (cons c (cons d (-spread more)))))))

(defn load-file [f] (-load-file-ly f))

(defn -load-file-ly [f]
  (eval
    (read-string
      (str
        "(do "
        (slurp f)
        "\nnil)"))))

(defn macro? [x] (instance? lingy.lang.Macro x))

(defn macroexpand [macro] (. lingy.lang.RT (macroexpand macro)))

(defn map [fn list] (. lingy.lang.RT (map fn list)))

(defn map? [x] (instance? lingy.lang.HashMap x))

(defn meta [object] (. lingy.lang.RT (meta_get object)))

(defn mod
  [num div]
  (let [m (rem num div)]
    (if (or (zero? m) (= (pos? num) (pos? div)))
      m
      (+ m div))))

(defn name [symbol] (. lingy.lang.RT (name symbol)))

(defn namespace [symbol] (. lingy.lang.RT (namespace symbol)))

(defn next [x] (seq (rest x)))

(defn nfirst [x] (next (first x)))

(defn nil? [x] (lingy.lang.Util/identical x nil))

(defn nnext [x] (next (next x)))

(defn not [a] (if a false true))

(defmacro ns [name & xs] `(lingy.lang.RT/ns_ '~name '~xs))

(defn ns-imports [ns]
  (.getImports (the-ns ns)))

(defn ns-interns [ns]
  (.getInterns (the-ns ns)))

(defn ns-map [ns]
  (.getMappings (the-ns ns)))

(defn ns-name [ns]
  (.getName (the-ns ns)))

(defn nth
  ([list index]
    (if (and (>= index 0) (< index (count list)))
      (. lingy.lang.RT (nth list index))
      (throw "Index out of bounds")))
  ([list index default]
    (if (and (>= index 0) (< index (count list)))
      (nth list index)
      default)))

(defmacro or
  ([] nil)
  ([x] x)
  ([x & next]
   `(let [or# ~x]
      (if or# or# (or ~@next)))))

(defn number [string] (. lingy.lang.RT (number_ string)))

(defn number? [x] (instance? lingy.lang.Number x))

(defn perl [string] (. lingy.lang.RT (eval_perl string)))

(defn pos? [num] (. lingy.lang.Numbers (isPos num)))

(defn pr-str [& xs] (apply lingy.lang.RT/pr_str xs))

(defn println [& args] (apply lingy.lang.RT/println args))

(defn prn [& args] (apply lingy.lang.RT/prn args))

(defn quot [x y] (. lingy.lang.RT (quot x y)))

(defn range [& args] (apply lingy.lang.Numbers/range args))

(defn read-string [string] (. lingy.lang.RT (read_string string)))

(defn readline [] (. lingy.lang.RT (readline)))

(defn reduce
  ([fn coll]
    (let [len (count coll)]
      (cond
        (= len 0) (apply fn [])
        (= len 1) (nth coll 0)
        :else (apply reduce [fn (first coll) (rest coll)] ))))
  ([fn val coll]
    (loop [v val, x (first coll), xs (rest coll)]
      (let [v1 (apply fn [v x])
            cnt (count xs)]
        (if (= 0 cnt)
          v1
          (recur v1 (first xs) (rest xs)))))))

(defn re-find [re s] (lingy.lang.Regex/find re s))

(defn re-matches [re s] (lingy.lang.Regex/matches re s))

(defn re-pattern [s] (lingy.lang.Regex/pattern s))

(defn refer [ns]
  (. *ns* refer ns)
  nil)

(defn rem
  [num div]
    (. lingy.lang.Numbers (remainder num div)))

(defn require [& xs]
  (apply lingy.lang.RT/require xs)
  nil)

(defn reset! [var val] (. lingy.lang.RT (reset_BANG var val)))

(defn resolve [symbol] (. lingy.lang.RT (resolve symbol)))

(defn rest [list] (. lingy.lang.RT (rest list)))

(defn second [x] (first (next x)))

(defn seq [list] (. lingy.lang.RT (seq list)))

(defn seq? [x] (instance? lingy.lang.ListClass x))

(defn sequential? [x] (instance? lingy.lang.Sequential x))

(defn slurp [file] (. lingy.lang.RT (slurp file)))

(defn special-symbol? [s]
  (contains? (. lingy.lang.Compiler specials) s))

(defn sort [coll] (. lingy.lang.RT (sort (seq coll))))

(defn str [& args] (apply lingy.lang.RT/str args))

(defn string? [x] (instance? lingy.lang.String x))

(defn swap! [atom fn & args] (. lingy.lang.RT (swap_BANG atom fn args)))

(defn symbol [string] (. lingy.lang.RT (symbol_ string)))

(defn symbol? [x] (instance? lingy.lang.Symbol x))

(defn the-ns [ns] (. lingy.lang.RT (the_ns ns)))

(defn time-ms [] (. lingy.lang.RT (time_ms)))

(defn true? [x] (lingy.lang.Util/identical x true))

(defn type [object] (. lingy.lang.RT (type_ object)))

(defn use [ns]
  (require ns)
  (refer ns))

(defmacro when
  [test & body]
  (list 'if test (cons 'do body)))

(defmacro when-not
  [test & body]
  (list 'if test nil (cons 'do body)))

(defn vals [value] (. lingy.lang.RT (vals value)))

(defn var [value] (. lingy.lang.RT (var value)))

(defn vec [value] (. lingy.lang.RT (vec value)))

(defn vector [& args] (apply lingy.lang.RT/vector_ args))

(defn vector? [x] (instance? lingy.lang.Vector x))

(defmacro when-let [bindings & body]
  (let [
    form (nth bindings 0)
    tst (nth bindings 1)]
    `(let [temp# ~tst]
      (when temp#
        (let [~form temp#]
          ~@body)))))

(defn with-meta [object meta]
  (. lingy.lang.RT (with_meta object meta)))

(defn zero?
  [num] (. lingy.lang.Numbers (isZero num)))

; Private functions:

; user=> (apply + 3 4 [5 6])
; 18
; user=> (eval (cons + (spread [3 4 [5 6]])))
; 18
(defn -spread [arglist]
  (cond
    (nil? arglist) nil
    (nil? (next arglist)) (seq (first arglist))
    :else (cons (first arglist) (-spread (next arglist)))))

; vim: ft=clojure:
