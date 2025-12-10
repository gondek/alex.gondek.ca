package main

import (
	"html/template"
	"os"
	"path/filepath"
	"runtime"
)

type Page struct {
	Template         string
	CssClass         string
	Content          string
	OutputPath       string
	PageSpecificData interface{}
}

func GetPages() []Page {
	return []Page{
		{
			Template:   "base",
			CssClass:   "home",
			Content:    "index",
			OutputPath: "index.html",
		},
	}
}

func BuildPages() error {
	_, scriptFilename, _, _ := runtime.Caller(0)
	repoRoot := filepath.Dir(filepath.Dir(scriptFilename))
	templatesPath := filepath.Join(repoRoot, "src", "templates", "*.gohtml")
	pagesPath := filepath.Join(repoRoot, "src", "pages", "*.gohtml")

	tmpl := template.Must(template.ParseGlob(templatesPath))
	template.Must(tmpl.ParseGlob(pagesPath))

	outputDir := os.Getenv("OUTPUT_DIR")
	buildDir := filepath.Join(repoRoot, outputDir)
	pages := GetPages()

	for _, page := range pages {
		outputPath := filepath.Join(buildDir, page.OutputPath)
		err := generatePage(outputPath, page, tmpl)
		if err != nil {
			return err
		}
	}

	return nil
}

func generatePage(outputPath string, page Page, tmpl *template.Template) error {
	f, err := os.Create(outputPath)
	if err != nil {
		return err
	}

	defer func(f *os.File) {
		_ = f.Close()
	}(f)

	if err := tmpl.ExecuteTemplate(f, page.Template, page); err != nil {
		return err
	}

	return nil
}

func main() {
	err := BuildPages()
	if err != nil {
		panic(err)
	}
}
