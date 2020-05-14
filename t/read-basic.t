use Spreadsheet::XLSX;
use Test;

given Spreadsheet::XLSX.load($*PROGRAM.parent.add('test-data/basic.xlsx')) {
    isa-ok $_, Spreadsheet::XLSX, 'Loaded gave a Spreadsheet::XLSX instance';

    given .content-types {
        isa-ok $_, Spreadsheet::XLSX::ContentTypes;
        is .defaults.elems, 3, 'Content type has 3 defaults';
        given .defaults[0] {
            is .extension, 'bin', 'Default has expected extension';
            is .content-type, 'application/vnd.openxmlformats-officedocument.spreadsheetml.printerSettings',
                'Default has expected content type';
        }
        is .overrides.elems, 8, 'Content type has 8 overrides';
        given .overrides[0] {
            is .part-name, '/xl/workbook.xml', 'Override has expected part name';
            is .content-type, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml',
                'Override has expected content type';
        }
        is-deeply .part-name-for-content-type('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml'),
                '/xl/workbook.xml',
                'Correct workbook part name';
        is-deeply .part-names-for-content-type('application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml'),
                ('/xl/worksheets/sheet1.xml', '/xl/worksheets/sheet2.xml').Seq,
                'Correct worksheet part names';
    }

    given .find-relationships('') {
        isa-ok $_, Spreadsheet::XLSX::Relationships;
        ok .defined, 'We can find the root relationships';
        is .relationships.elems, 3, 'There are 3 root relationships';
        given .find-by-id('rId2') {
            is .id, 'rId2', 'Find by ID works (id)';
            is .type, 'http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties',
                    'Find by ID works (type)';
            is .target, 'docProps/core.xml', 'Find by ID works (target)';
        }
        fails-like { .find-by-id('blah') },
            X::Spreadsheet::XLSX::NoSuchRelationship,
            id => 'blah';
        given .find-by-type('http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument') {
            is .elems, 1, 'Found one element by type';
            is .[0].id, 'rId1', 'Correct id in by type result';
            is .[0].type, 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument',
                'Correct type in type result';
            is .[0].target, 'xl/workbook.xml',
                'Correct target in type result';
        }
    }
}

done-testing;