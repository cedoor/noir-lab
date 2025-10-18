// This circuit demonstrates the use of generics in Noir.
// It repeats a multiplication operation N times.
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

// add a test here please
#[test]
fn test_repeat() {
    let result = repeat::<10>(2);

    assert_eq(result, 1024);
}
