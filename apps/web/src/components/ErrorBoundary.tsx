import React, { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
  errorInfo: ErrorInfo | null;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
    };
  }

  static getDerivedStateFromError(error: Error): Partial<State> {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo);
    this.setState({
      error,
      errorInfo,
    });
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{
          padding: '40px',
          maxWidth: '800px',
          margin: '0 auto',
          fontFamily: 'monospace',
        }}>
          <div style={{
            background: '#fee',
            border: '2px solid #c33',
            borderRadius: '8px',
            padding: '20px',
          }}>
            <h1 style={{ color: '#c33', marginTop: 0 }}>⚠️ Application Error</h1>
            <h2 style={{ color: '#666' }}>Something went wrong</h2>

            <details style={{ marginTop: '20px' }}>
              <summary style={{ cursor: 'pointer', fontWeight: 'bold', marginBottom: '10px' }}>
                Error Details
              </summary>
              <div style={{
                background: '#333',
                color: '#0f0',
                padding: '15px',
                borderRadius: '4px',
                overflow: 'auto',
                marginTop: '10px',
              }}>
                <p><strong>Error:</strong> {this.state.error?.toString()}</p>
                <p><strong>Stack:</strong></p>
                <pre style={{ whiteSpace: 'pre-wrap', fontSize: '12px' }}>
                  {this.state.error?.stack}
                </pre>
                {this.state.errorInfo && (
                  <>
                    <p><strong>Component Stack:</strong></p>
                    <pre style={{ whiteSpace: 'pre-wrap', fontSize: '12px' }}>
                      {this.state.errorInfo.componentStack}
                    </pre>
                  </>
                )}
              </div>
            </details>

            <button
              onClick={() => window.location.reload()}
              style={{
                marginTop: '20px',
                padding: '10px 20px',
                background: '#c33',
                color: 'white',
                border: 'none',
                borderRadius: '4px',
                cursor: 'pointer',
                fontSize: '16px',
              }}
            >
              Reload Page
            </button>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}
