# ===----------------------------------------------------------------------=== #
# Copyright (c) 2025, Modular Inc. All rights reserved.
#
# Licensed under the Apache License v2.0 with LLVM Exceptions:
# https://llvm.org/LICENSE.txt
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ===----------------------------------------------------------------------=== #

from builtin.range import _StridedRangeIterator, _UIntStridedRangeIterator

# ===-----------------------------------------------------------------------===#
# __MLIRType
# ===-----------------------------------------------------------------------===#


@register_passable("trivial")
struct __MLIRType[T: AnyTrivialRegType](Movable, Copyable, ExplicitlyCopyable):
    var value: T

    fn copy(self) -> Self:
        return self


# ===-----------------------------------------------------------------------===#
# parameter_for
# ===-----------------------------------------------------------------------===#


trait _IntNext(Copyable):
    fn __next__(mut self) -> Int:
        ...


trait _UIntNext(Copyable):
    fn __next__(mut self) -> UInt:
        ...


trait _IntIter(_IntNext):
    fn __len__(self) -> Int:
        ...


trait _UIntIter(_UIntNext):
    fn __len__(self) -> UInt:
        ...


trait _IntIterable(_IntIter):
    fn __iter__(self) -> Self:
        ...


trait _UIntIterable(_UIntIter):
    fn __iter__(self) -> Self:
        ...


trait _StridedIterable(_IntIter):
    fn __iter__(self) -> _StridedRangeIterator:
        ...


trait _UIntStridedIterable(_UIntIter):
    fn __iter__(self) -> _UIntStridedRangeIterator:
        ...


struct _ParamForIterator[IteratorT: Copyable]:
    var next_it: IteratorT
    var value: Int
    var stop: Bool

    fn __init__(out self, next_it: IteratorT, value: Int, stop: Bool):
        self.next_it = next_it
        self.value = value
        self.stop = stop


struct _UIntParamForIterator[IteratorT: Copyable]:
    var next_it: IteratorT
    var value: UInt
    var stop: Bool

    fn __init__(out self, next_it: IteratorT, value: UInt, stop: Bool):
        self.next_it = next_it
        self.value = value
        self.stop = stop


fn declval[T: AnyType]() -> T:
    constrained[False, "should only be used inside __type_of"]()
    while True:
        pass


fn parameter_for_generator[
    T: _IntIterable,
](range: T) -> _ParamForIterator[__type_of(declval[T]().__iter__())]:
    return _generator(range.__iter__())


fn parameter_for_generator[
    T: _UIntIterable,
](range: T) -> _UIntParamForIterator[__type_of(declval[T]().__iter__())]:
    return _generator(range.__iter__())


fn parameter_for_generator[
    T: _StridedIterable,
](range: T) -> _ParamForIterator[__type_of(declval[T]().__iter__())]:
    return _generator(range.__iter__())


fn parameter_for_generator[
    T: _UIntStridedIterable,
](range: T) -> _UIntParamForIterator[__type_of(declval[T]().__iter__())]:
    return _generator(range.__iter__())


fn _generator[
    IteratorT: _IntIter
](it: IteratorT) -> _ParamForIterator[IteratorT]:
    if it.__len__() != 0:
        var next_it = it
        return _ParamForIterator(next_it, next_it.__next__(), False)

    var value: IteratorT
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(value))
    return _ParamForIterator(value^, 0, True)


fn _generator[
    IteratorT: _UIntIter
](it: IteratorT) -> _UIntParamForIterator[IteratorT]:
    if it.__len__() != 0:
        var next_it = it
        return _UIntParamForIterator(next_it, next_it.__next__(), False)

    var value: IteratorT
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(value))
    return _UIntParamForIterator(value^, 0, True)
