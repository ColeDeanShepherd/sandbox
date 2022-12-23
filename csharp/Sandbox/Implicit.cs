using System.Collections.Immutable;

namespace Sandbox;

public struct Implicit<T>
{
    public class WithScope : IDisposable
    {
        private bool _disposedValue;

        protected virtual void Dispose(bool disposing)
        {
            if (!_disposedValue)
            {
                if (disposing)
                {
                    _valueStack.Value = _valueStack.Value!.Pop();
                }

                _disposedValue = true;
            }
        }

        public void Dispose()
        {
            Dispose(disposing: true);
            GC.SuppressFinalize(this);
        }
    }

    public static WithScope With(T t)
    {
        _valueStack.Value = _valueStack.Value!.Push(t);
        return new WithScope();
    }

    private static AsyncLocal<ImmutableStack<T>> _valueStack;

    static Implicit()
    {
        _valueStack = new();
        _valueStack.Value = ImmutableStack<T>.Empty;
    }

    public T Value => _valueStack.Value!.Peek();
}
