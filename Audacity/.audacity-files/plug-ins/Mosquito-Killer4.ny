;nyquist plug-in
;version 4
;type process
;name "Mosquito-Killer4..."
;type process

;control iter "How many mosquitos to kill ?" int "1 - 16" 8 1 16

(let ((maxhz (min (* iter 1000)(/ *sound-srate* 2.1))))
  (do ((hz 1000 (+ hz 1000))
       (q 20 (+ q 20)))
      ((> hz maxhz) *track*)
    ; (print hz)
    (setf *track* (notch2 *track* hz q))))

