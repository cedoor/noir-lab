// This circuit demonstrates the use of generics in Noir.
// It repeats a multiplication operation N times.
//
// Use const generics (<let N: u32>) when N affects circuit structure (loop bounds, array sizes).
// Use runtime parameters only when N doesn't change circuit shape - but note that loop bounds
// must be compile-time constants in Noir, so variable iteration requires fixed max + gating.
fn main(a: pub Field, b: Field) -> pub (Field) {
    repeat::<2048>(a + b)
}

fn repeat<let N: u32>(n: Field) -> Field {
    let mut result = n;

    for _i in 0..(N - 1) {
        result = result * n;
    }

    result
}

#[test]
fn test_repeat() {
    let result = repeat::<10>(2);

    assert_eq(result, 1024);
}
