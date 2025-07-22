import React from "react";
import ErrorBoundary from "../error/ErrorBoundary";

interface LayoutProps {
  children: React.ReactNode;
  className?: string;
}

export const Page: React.FC<LayoutProps> = ({ children, className = "" }) => {
  return (
    <ErrorBoundary
      feature="page"
      onError={(error, errorInfo, context) => {
        // Error handling callback - could integrate with logging service here
      }}
    >
      <div className={`min-h-screen bg-gray-50 ${className}`}>{children}</div>
    </ErrorBoundary>
  );
};

export const PageHeader: React.FC<LayoutProps> = ({
  children,
  className = "",
}) => (
  <div className={`bg-white border-b border-gray-200 ${className}`}>
    <Container>
      <div className="py-6">{children}</div>
    </Container>
  </div>
);

export const PageContent: React.FC<LayoutProps> = ({
  children,
  className = "",
}) => (
  <Container className={className}>
    <div className="py-8">{children}</div>
  </Container>
);

export const Container: React.FC<LayoutProps> = ({
  children,
  className = "",
}) => (
  <div className={`max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 ${className}`}>
    {children}
  </div>
);

export const FlexBetween: React.FC<LayoutProps> = ({
  children,
  className = "",
}) => (
  <div className={`flex items-center justify-between ${className}`}>
    {children}
  </div>
);

export const FlexCenter: React.FC<LayoutProps> = ({
  children,
  className = "",
}) => (
  <div className={`flex items-center space-x-3 ${className}`}>{children}</div>
);

interface GridProps extends LayoutProps {
  cols?: string;
  gap?: string;
}

export const Grid: React.FC<GridProps> = ({
  cols = "1 md:2 lg:3",
  gap = "6",
  children,
  className = "",
}) => (
  <div className={`grid grid-cols-${cols} gap-${gap} ${className}`}>
    {children}
  </div>
);

export const Card: React.FC<LayoutProps> = ({ children, className = "" }) => (
  <div
    className={`bg-white rounded-xl shadow-sm border border-gray-200 p-6 ${className}`}
  >
    {children}
  </div>
);
